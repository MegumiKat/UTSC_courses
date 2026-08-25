import { expect } from 'chai';
import request from 'supertest';
import { server } from '../app.mjs';  // 引入你的 Express 应用
import path from 'path';
import fs from 'fs';


process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';  // 忽略自签名证书验证

describe('Image Gallery API', () => {
    let agent;
    let imageId;

    // 在所有测试开始前创建 agent 并确保用户已注册
    before((done) => {
        agent = request.agent(server);  // 创建一个 agent 以维护会话

        // 确保用户存在
        agent
            .post('/signup')
            .send({ username: 'testuser', password: 'testpass' })
            .end((err, res) => {
                if (err && res.status !== 409) return done(err);  // 忽略重复用户错误
                agent
                    .post('/signin')
                    .send({ username: 'testuser', password: 'testpass' })
                    .end((err, res) => {
                        if (err) return done(err);
                        done();
                    });
            });
    });

    after(() => {
        server.close();
    });

    // 获取用户列表测试
    describe('GET /api/users', () => {
        it('should return a list of users', (done) => {
            agent
                .get('/api/users')
                .expect(200)
                .end((err, res) => {
                    if (err) return done(err);
                    expect(res.body).to.be.an('array');
                    done();
                });
        });
    });

    // 获取图片列表测试
    describe('GET /api/images', () => {
        it('should return all images', (done) => {
            agent
                .get('/api/images')
                .expect(200)
                .end((err, res) => {
                    if (err) return done(err);
                    expect(res.body).to.be.an('array');
                    done();
                });
        });
    });

    // 上传图片测试
    describe('POST /api/images', () => {
        it('should upload a new image', (done) => {

            agent
                .post('/api/images')
                .field('title', 'Test Image')
                .field('author', 'testuser')
                .attach('file', fs.readFileSync('./test.png'), 'test.png')
                .expect(200)
                .end((err, res) => {
                    if (err) return done(err);
                    expect(res.body).to.have.property('_id');
                    expect(res.body).to.have.property('url');
                    imageId = res.body._id;
                    done();
                });
        });
    });


    // 删除图片测试
    describe('DELETE /api/images/:id', () => {
        let deleteImageId;

        // 先上传一张图片供删除
        before((done) => {

            agent
                .post('/api/images')
                .field('title', 'Test Image for Deletion')
                .field('author', 'testuser')
                .attach('file', fs.readFileSync('./test.png'), 'test.png')
                .end((err, res) => {
                    if (err) return done(err);
                    deleteImageId = res.body._id;
                    done();
                });
        });

        it('should delete an image by ID', (done) => {
            agent
                .delete(`/api/images/${deleteImageId}`)
                .expect(200)
                .end((err, res) => {
                    if (err) return done(err);
                    expect(res.body).to.have.property('success', true);
                    done();
                });
        });
    });

    // 评论测试
    describe('POST /api/comments', () => {
        let testCommentId;

        it('should add a new comment to an image', (done) => {
            agent
                .post('/api/comments')
                .send({
                    imageId: imageId,
                    author: 'testuser',
                    content: 'This is a test comment',
                })
                .expect(200)
                .end((err, res) => {
                    if (err) return done(err);
                    expect(res.body).to.have.property('_id');
                    testCommentId = res.body._id;
                    done();
                });
        });

        it('should get comments for an image', (done) => {
            agent
                .get('/api/comments')
                .query({ imageId: imageId })
                .expect(200)
                .end((err, res) => {
                    if (err) return done(err);
                    expect(res.body).to.be.an('array');
                    expect(res.body[0]).to.have.property('content', 'This is a test comment');
                    done();
                });
        });

        it('should delete a comment by ID', (done) => {
            agent
                .delete(`/api/comments/${testCommentId}`)
                .expect(200)
                .end((err, res) => {
                    if (err) return done(err);
                    expect(res.body).to.have.property('success', true);
                    done();
                });
        });
    });
});