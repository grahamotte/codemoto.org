class Plane
  HOST = "https://api.plane.so"
  APP = "https://app.plane.so"

  class << self
    def reset
      @project_id = nil
      @states = nil
    end

    def work_items
      results(
        Req.call(
          url: "#{project_url}/work-items/",
          headers:,
          params: { expand: "state", per_page: 100 },
        ),
      )
    end

    def move(item, column)
      Req.call(
        url: "#{project_url}/work-items/#{item.fetch(:id)}/",
        method: :patch,
        headers:,
        payload: { state: state_id(column) },
      )
    end

    def column(item)
      state = item[:state]
      return state[:name].downcase if state.is_a?(Hash) && state[:name].present?
      return states_by_id[state] if state.present?

      nil
    end

    def url(item)
      "#{APP}/#{workspace}/browse/#{project}-#{item.fetch(:sequence_id)}/"
    end

    private

    def workspace
      ENV.fetch("PLANE_WORKSPACE")
    end

    def project
      ENV.fetch("PLANE_PROJECT")
    end

    def headers
      { "X-API-Key" => ENV.fetch("PLANE_TOKEN") }
    end

    def project_url
      "#{HOST}/api/v1/workspaces/#{workspace}/projects/#{project_id}"
    end

    def project_id
      @project_id ||= results(
        Req.call(
          url: "#{HOST}/api/v1/workspaces/#{workspace}/projects/",
          headers:,
        ),
      ).find { |item| item.fetch(:identifier) == project }.fetch(:id)
    end

    def state_id(column)
      states.fetch(column)
    end

    def states
      @states ||= results(
        Req.call(
          url: "#{project_url}/states/",
          headers:,
        ),
      ).to_h { |state| [ state.fetch(:name).downcase, state.fetch(:id) ] }
    end

    def states_by_id
      states.invert
    end

    def results(response)
      return response if response.is_a?(Array)

      response.fetch(:results)
    end
  end
end
