import path from "path";
import { init, emulator, getAccountAddress, sendTransaction } from "flow-js-testing";

(async () => {
  const basePath = path.resolve(__dirname, "./cadence");
  const port = 8080;

  await init(basePath, { port });

  emulator.addFilter(`debug`);

  //const Alice = await getAccountAddress("Alice");

  const name = "init";

  const signers = ["0xf8d6e0586b0a20c7"];
  const args = [];

  const [txFileResult] = await sendTransaction({ name, signers, args });

  console.log("txFileResult", txFileResult);

  // 3. Providing name of the file in short form (name, signers, args)
  const [txShortResult] = await sendTransaction(name, signers, args);
  console.log("txShortResult", txShortResult);

})();
