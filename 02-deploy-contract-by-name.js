import path from "path";
import { init, emulator, deployContractByName, executeScript } from "flow-js-testing";

(async () => {
  try {
      // Init framework
  const basePath = path.resolve(__dirname, "./cadence");
  const port = 8080;
  await init(basePath, { port });

  await deployContractByName({
    name: "FungibleToken"
  });

  await deployContractByName({ name: "FUSD" });

  await deployContractByName({ name: "TokenLendingPlace" });

  }catch (err) {
    console.log(err);
  }

})();
