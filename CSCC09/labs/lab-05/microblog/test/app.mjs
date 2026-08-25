import { readFileSync } from "fs";
import chai from "chai";
import chaiHttp from "chai-http";

import { server } from "../app.mjs";

const expect = chai.expect;
chai.use(chaiHttp);

describe("Testing API", () => {
  after(function () {
    server.close();
  });

  it("it should add a user", function (done) {
    throw new Error("This test does not work yet");
    done();
  });
});
