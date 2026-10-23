const request = require('supertest');
const buildApp = require('../../../app');
const UserRepo = require('../../../repos/user-repo');
const pool = require('../../../pool');
//const expectCookies = require('supertest/lib/cookies');

beforeAll(() => {
  return pool.connect({
    host: 'localhost',
    port: 5432,
    database: 'socialnetwork-test',
    user: 'postgres',
    password: 'Password123!',
  });
});

afterAll(() => {
  return pool.close();
});

it('create a user', async () => {
  const startingCount = await UserRepo.count(0);
  expect(startingCount).toEqual(0);

  await request(buildApp())
    .post('/users')
    .send({ username: 'testuser', bio: 'test bio' })
    .expect(200);

  const finishCount = await UserRepo.count();
  expect(finishCount).toEqual(1); 
});