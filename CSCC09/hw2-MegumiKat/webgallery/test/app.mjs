import chaiHttp from 'chai-http';
import { use, expect } from 'chai';
const chai = use(chaiHttp);
import { server } from '../app.mjs';  // Import the server to test against
import fs from 'fs';  // To handle file reading for upload

describe('Testing API', () => {
    let testImageId;
    let testCommentId;

    after(() => {
        server.close();
    });


    it('should add a new image', (done) => {
        chai.request.execute(server)
            .post('/api/images')
            .field('title', 'Test Image')
            .field('author', 'Test Author')
            .attach('file', fs.readFileSync('./test.png'), 'test.png')
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body).to.have.property('_id');
                testImageId = res.body._id;
                done();
            });
    });


    // Test retrieving all images
    it('should get all images', (done) => {
        chai.request.execute(server)
            .get('/api/images')
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body).to.be.an('array');
                done();
            });
    });


    it('should get a specific image by ID', (done) => {
        chai.request.execute(server)
            .get(`/api/images/${testImageId}`)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body).to.have.property('_id').equal(testImageId);
                done();
            });
    });


    it('should delete an image by ID', (done) => {
        chai.request.execute(server)
            .delete(`/api/images/${testImageId}`)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body).to.have.property('success', true);
                done();
            });
    });


    it('should add a new comment', (done) => {
        chai.request.execute(server)
            .post('/api/comments')
            .send({
                imageId: testImageId,
                author: 'Test Commenter',
                content: 'This is a test comment',
            })
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body).to.have.property('_id');
                testCommentId = res.body._id;
                done();
            });
    });

    it('should get comments for an image', (done) => {
        chai.request.execute(server)
            .get('/api/comments')
            .query({ imageId: testImageId })
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body).to.be.an('array');
                done();
            });
    });


    it('should delete a comment by ID', (done) => {
        chai.request.execute(server)
          .delete(`/api/comments/${testCommentId}`)
          .end((err, res) => {
            expect(res).to.have.status(200);
            expect(res.body).to.have.property('success', true);
            done();
          });
      });


});