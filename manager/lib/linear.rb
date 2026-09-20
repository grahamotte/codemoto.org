class Linear
  HOST = "https://api.linear.app/graphql"
  STATUSES = [
    { name: "Backlog", type: "backlog", color: "#f2994a" },
    { name: "Planned", type: "unstarted", color: "#95a2b3" },
    { name: "Ready", type: "started", color: "#f2c94c" },
    { name: "Working", type: "started", color: "#f2c94c" },
    { name: "Review", type: "started", color: "#f2c94c" },
    { name: "Approved", type: "started", color: "#f2c94c" },
    { name: "Completed", type: "completed", color: "#5e6ad2" },
    { name: "Canceled", type: "canceled", color: "#95a2b3" },
  ].freeze

  class << self
    def reset
      @team_id = nil
      @states = nil
    end

    def issues
      nodes = []
      after = nil
      loop do
        page = graphql(
          ISSUES_QUERY,
          { teamId: team_id, after: }.compact,
        ).fetch(:team).fetch(:issues)
        nodes.concat(page.fetch(:nodes))
        break unless page.dig(:pageInfo, :hasNextPage)

        after = page.dig(:pageInfo, :endCursor)
        break if after.blank?
      end
      nodes
    end

    def move(item, column)
      graphql(
        ISSUE_UPDATE_MUTATION,
        { id: item.fetch(:id), input: { stateId: state_id(column) } },
      )
    end

    def column(item)
      state = item[:state]
      return state[:name].downcase if state.is_a?(Hash) && state[:name].present?
      return states_by_id[state] if state.present?

      nil
    end

    def identifier(item)
      item.fetch(:identifier)
    end

    def url(item)
      item.fetch(:url)
    end

    def sync_statuses
      current = state_nodes
      used_ids = []

      STATUSES.each_with_index do |want, index|
        existing = match_state(current, want, used_ids)
        position = STATUSES.take(index).count { |status| status[:type] == want[:type] }.to_f
        if existing
          used_ids << existing.fetch(:id)
          input = {}
          input[:name] = want[:name] if existing[:name] != want[:name]
          input[:color] = want[:color] if existing[:color] != want[:color]
          input[:position] = position if existing[:position] != position
          next if input.blank?

          graphql(STATE_UPDATE_MUTATION, { id: existing.fetch(:id), input: })
          puts "renamed #{existing[:name]} to #{want[:name]}" if input[:name].present?
        else
          graphql(
            STATE_CREATE_MUTATION,
            {
              input: {
                teamId: team_id,
                name: want[:name],
                type: want[:type],
                color: want[:color],
                position:,
              },
            },
          )
          puts "created #{want[:name]}"
        end
      end

      current.each do |state|
        next if used_ids.include?(state.fetch(:id))
        next if state[:type] == "duplicate"

        begin
          graphql(STATE_ARCHIVE_MUTATION, { id: state.fetch(:id) })
          puts "removed #{state[:name]}"
        rescue StandardError => error
          raise unless error.message.to_s.include?("reserved")
        end
      end

      @states = nil
    end

    private

    WORKSPACE_QUERY = <<~GQL
      query Workspace($key: String!) {
        organization {
          urlKey
        }
        teams(filter: { key: { eq: $key } }) {
          nodes {
            id
            key
          }
        }
      }
    GQL

    STATES_QUERY = <<~GQL
      query States($teamId: String!) {
        team(id: $teamId) {
          states {
            nodes {
              id
              name
              type
              color
              position
            }
          }
        }
      }
    GQL

    ISSUES_QUERY = <<~GQL
      query Issues($teamId: String!, $after: String) {
        team(id: $teamId) {
          issues(first: 100, after: $after) {
            nodes {
              id
              identifier
              url
              state {
                id
                name
              }
            }
            pageInfo {
              hasNextPage
              endCursor
            }
          }
        }
      }
    GQL

    ISSUE_UPDATE_MUTATION = <<~GQL
      mutation IssueUpdate($id: String!, $input: IssueUpdateInput!) {
        issueUpdate(id: $id, input: $input) {
          success
        }
      }
    GQL

    STATE_CREATE_MUTATION = <<~GQL
      mutation WorkflowStateCreate($input: WorkflowStateCreateInput!) {
        workflowStateCreate(input: $input) {
          success
        }
      }
    GQL

    STATE_UPDATE_MUTATION = <<~GQL
      mutation WorkflowStateUpdate($id: String!, $input: WorkflowStateUpdateInput!) {
        workflowStateUpdate(id: $id, input: $input) {
          success
        }
      }
    GQL

    STATE_ARCHIVE_MUTATION = <<~GQL
      mutation WorkflowStateArchive($id: String!) {
        workflowStateArchive(id: $id) {
          success
        }
      }
    GQL

    def workspace
      ENV.fetch("LINEAR_WORKSPACE")
    end

    def team
      ENV.fetch("LINEAR_TEAM")
    end

    def headers
      { "Authorization" => ENV.fetch("LINEAR_TOKEN") }
    end

    def team_id
      @team_id ||= begin
        data = graphql(WORKSPACE_QUERY, { key: team })
        url_key = data.fetch(:organization).fetch(:urlKey)
        unless url_key == workspace
          raise "Linear workspace is #{url_key.inspect}, expected #{workspace.inspect}"
        end

        found = data.fetch(:teams).fetch(:nodes).find { |item| item.fetch(:key) == team }
        raise "Linear team #{team.inspect} not found" if found.blank?

        found.fetch(:id)
      end
    end

    def state_id(column)
      states.fetch(column)
    end

    def states
      @states ||= state_nodes.to_h { |state| [ state.fetch(:name).downcase, state.fetch(:id) ] }
    end

    def states_by_id
      states.invert
    end

    def state_nodes
      graphql(STATES_QUERY, { teamId: team_id }).fetch(:team).fetch(:states).fetch(:nodes)
    end

    def match_state(current, want, used_ids)
      current.find do |state|
        !used_ids.include?(state.fetch(:id)) &&
          state[:name].to_s.downcase == want[:name].downcase &&
          state[:type] == want[:type]
      end || current.find do |state|
        !used_ids.include?(state.fetch(:id)) &&
          state[:type] == want[:type] &&
          STATUSES.none? { |status| status[:name].downcase == state[:name].to_s.downcase }
      end
    end

    def graphql(query, variables = {})
      response = Req.call(
        url: HOST,
        method: :post,
        headers:,
        payload: { query:, variables: },
      )
      errors = response[:errors]
      raise errors.first[:message] if errors.present?

      response.fetch(:data)
    end
  end
end
