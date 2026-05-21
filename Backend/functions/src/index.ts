import {setGlobalOptions} from "firebase-functions";

setGlobalOptions({
  maxInstances: 10,
  region: "southamerica-east1",
});

export * from "./users";
export * from "./startups";
export * from "./wallet";
export * from "./exchange";
