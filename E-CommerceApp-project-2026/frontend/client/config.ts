interface Config {
  baseUrl: string;
}

const checkConfig = (server: string): Config | {} => {
  let config: Config | {} = {};

  switch (server) {
    case "production":
      config = {
        baseUrl: "",
      };
      break;

    case "local":
      config = {
        baseUrl: "http://localhost:5000",
      };
      break;

    case "network":
      config = {
        baseUrl: "http://192.168.10.100:5000",
      };
      break;

    default:
      break;
  }

  return config;
};

export const selectServer = "local";
export const config = checkConfig(selectServer) as Config;