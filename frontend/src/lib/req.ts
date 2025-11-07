import Axios from "axios";
import * as changeKeys from "change-case/keys";
import { z } from "zod";

export const token = () => localStorage.getItem("jwt");

export const loggedIn = () => !!parsedToken();

export const parsedToken = () => {
  try {
    const t = JSON.parse(atob((token() || "").split(".")[1]) || "{}");
    if (Math.floor(Date.now() / 1000) > t.exp) return null;
    return t;
  } catch (e) {
    return null;
  }
};

export const req = async <T extends z.ZodSchema<any>>({
  method,
  url,
  data,
  params,
  headers,
  schema,
}: {
  url: string;
  schema: T;
  method?: string;
  data?: any;
  params?: any;
  headers?: any;
}) => {
  type InferFromSchema<T extends z.ZodSchema<any>> = z.infer<T>;
  let res;
  params ||= {};
  try {
    res = await Axios.request<InferFromSchema<T>>({
      method: method || "get",
      responseType: "json",
      url: url,
      params: changeKeys.snakeCase({ ...params }, 999),
      data: changeKeys.snakeCase({ ...data }, 999),
      headers: {
        Authorization: `Bearer ${token()}`,
        ...headers,
      },
    });

    if (res.headers["refresh-token"]) {
      localStorage.setItem("jwt", res.headers["refresh-token"]);
    }

    console.log(url, params, res?.data);

    return (schema || z.any()).parse(
      changeKeys.camelCase(res.data, 999)
    ) as InferFromSchema<T>;
  } catch (e) {
    console.log(url, params, res?.data);
    console.log(e);

    if ((e as any).response && (e as any).response.status === 401)
      void logout();

    throw e;
  }
};

export const login = ({
  handle,
  password,
}: {
  handle: string;
  password: string;
}) => {
  return req({
    url: "/api/users/jwt",
    data: { handle: handle, password: password },
    schema: z.any(),
  }).then((data) => {
    localStorage.setItem("jwt", data.token);
  });
};

export const logout = () => {
  return new Promise((r: any) => {
    localStorage.removeItem("jwt");
    void req({ url: "/api/users/logout", schema: z.any() });
    r();
  });
};
