import { readFileSync } from "fs";
import chaiHttp from "chai-http";

import { use, expect } from 'chai';
const chai = use(chaiHttp);

import { server } from "../app.mjs";

describe("Testing API", () => {
  let testMessageId;
  after(function () {
    server.close();
  });

  it("should add a message", function (done) {
    const message = {
      content: "Hello, this is a test message",
      author: "Tester"
    };

    chai
      .request.execute(server)
      .post("/api/messages/")
      .send(message)
      .end(function (err, res) {
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property("id");
        expect(res.body.content).to.equal(message.content);
        expect(res.body.author).to.equal(message.author);
        testMessageId = res.body.id;
        done();
      });
  });

  it("should retrieve all messages", function (done) {
    chai
      .request.execute(server)
      .get("/api/messages/")
      .end(function (err, res) {
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property("total").that.is.a("number");
        expect(res.body).to.have.property("messages").that.is.an("array");
        done();
      });
  });

  it("should retrieve a specific message by ID", function (done) {
    chai
      .request.execute(server)
      .get(`/api/messages/${testMessageId}/`)
      .end(function (err, res) {
        expect(res.status).to.equal(200);
        expect(res.body).to.be.an("object");
        expect(res.body).to.have.property("id", testMessageId);
        expect(res.body.content).to.equal("Hello, this is a test message");
        done();
      });
  });

  it("should upvote a message", function (done) {
    chai
      .request.execute(server)
      .patch(`/api/messages/${testMessageId}/`)
      .send({ action: "upvote" })
      .end(function (err, res) {
        expect(res.status).to.equal(200);
        expect(res.body.upvote).to.equal(1);
        done();
      });
  });

  it("should downvote a message", function (done) {
    chai
      .request.execute(server)
      .patch(`/api/messages/${testMessageId}/`)
      .send({ action: "downvote" })
      .end(function (err, res) {
        expect(res.status).to.equal(200);
        expect(res.body.downvote).to.equal(1);
        done();
      });
  });

  it("should delete a message", function (done) {
    chai
      .request.execute(server)
      .delete(`/api/messages/${testMessageId}/`)
      .end(function (err, res) {
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property("id").that.equals(testMessageId);
        done();
      });
  });




});
