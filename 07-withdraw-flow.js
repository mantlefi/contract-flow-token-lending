import path from "path";
import { init, emulator, getAccountAddress, sendTransaction } from "flow-js-testing";

(async () => {
  const basePath = path.resolve(__dirname, "./cadence");
  const port = 8080;

  await init(basePath, { port });

  emulator.addFilter(`debug`);

  const name = "withdrawFlow";

  const signers = ["0xf8d6e0586b0a20c7"];
  const args = [10];

  // There are several ways to call "sendTransaction"
  // 1. Providing "code" field for Cadence template
  // 2. Providing "name" field to read Cadence template from file in "./transaction" folder
  const [txFileResult] = await sendTransaction({ name, signers, args });

  console.log("txFileResult", txFileResult);

})();
