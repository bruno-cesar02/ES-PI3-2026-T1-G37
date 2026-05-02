import {setGlobalOptions} from "firebase-functions";

setGlobalOptions({
  maxInstances: 10,
  region: "southamerica-east1",
});
export * from "./users";
