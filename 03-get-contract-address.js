import path from "path";
import { init, emulator, deployContractByName, getContractAddress } from "flow-js-testing";

(async () => {
  const basePath = path.resolve(__dirname, "./cadence");
  const port = 8080;

  await init(basePath, { port });

  const contractAddress = await getContractAddress("TokenLendingPlace");
  console.log({ contractAddress });

  //await emulator.stop();
})();
