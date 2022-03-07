import path from "path";
import { init, executeScript } from "flow-js-testing";

(async () => {
  const basePath = path.resolve(__dirname, "./cadence");
  const port = 8080;

  await init(basePath, { port });

  
const args = [
    "0xf8d6e0586b0a20c7"
  ];
  const name = "getFUSDBalance";

  const [fromFile] = await executeScript({ name, args });
  console.log({ fromFile });

})();
