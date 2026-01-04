import request from 'supertest';
import { app } from '../index';
import { pool } from '../config/database';

describe('API Tests - User Authentication', () => {
  let testUserToken: string;
  let testUserId: number;

  beforeAll(async () => {
    // 等待数据库连接
    await new Promise(resolve => setTimeout(resolve, 1000));
  });

  afterAll(async () => {
    // 清理测试数据
    if (testUserId) {
      await pool.query('DELETE FROM users WHERE id = $1', [testUserId]);
    }
    await pool.end();
  });

  describe('POST /api/auth/register', () => {
    it('should register a new user successfully', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: `test${Date.now()}@example.com`,
          password: 'test123456',
          nickname: 'Test User',
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('token');
      expect(response.body.data.user).toHaveProperty('id');
      expect(response.body.data.user.email).toBeDefined();

      testUserToken = response.body.data.token;
      testUserId = response.body.data.user.id;
    });

    it('should fail with invalid email format', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'invalid-email',
          password: 'test123456',
          nickname: 'Test User',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should fail with short password', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: `test${Date.now()}@example.com`,
          password: '123',
          nickname: 'Test User',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should fail with duplicate email', async () => {
      const email = `test${Date.now()}@example.com`;
      
      // 第一次注册
      await request(app)
        .post('/api/auth/register')
        .send({
          email,
          password: 'test123456',
          nickname: 'Test User',
        });

      // 第二次注册相同邮箱
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email,
          password: 'test123456',
          nickname: 'Test User 2',
        });

      expect(response.status).toBe(409);
      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /api/auth/login', () => {
    const testEmail = `login${Date.now()}@example.com`;
    const testPassword = 'test123456';

    beforeAll(async () => {
      // 创建测试用户
      await request(app)
        .post('/api/auth/register')
        .send({
          email: testEmail,
          password: testPassword,
          nickname: 'Login Test User',
        });
    });

    it('should login successfully with correct credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: testEmail,
          password: testPassword,
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('token');
      expect(response.body.data.user.email).toBe(testEmail);
    });

    it('should fail with incorrect password', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: testEmail,
          password: 'wrongpassword',
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });

    it('should fail with non-existent email', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'nonexistent@example.com',
          password: testPassword,
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });

    it('should fail with missing credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({});

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /api/auth/me', () => {
    it('should get current user info with valid token', async () => {
      const response = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${testUserToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('id');
      expect(response.body.data).toHaveProperty('email');
    });

    it('should fail without token', async () => {
      const response = await request(app)
        .get('/api/auth/me');

      expect(response.status).toBe(401);
    });

    it('should fail with invalid token', async () => {
      const response = await request(app)
        .get('/api/auth/me')
        .set('Authorization', 'Bearer invalid-token');

      expect(response.status).toBe(401);
    });
  });
});

describe('API Tests - Methods Management', () => {
  describe('GET /api/methods', () => {
    it('should get methods list without authentication', async () => {
      const response = await request(app)
        .get('/api/methods')
        .query({ page: 1, pageSize: 10 });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('list');
      expect(response.body.data).toHaveProperty('total');
      expect(Array.isArray(response.body.data.list)).toBe(true);
    });

    it('should filter methods by category', async () => {
      const response = await request(app)
        .get('/api/methods')
        .query({ category: '放松技巧' });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should support pagination', async () => {
      const response = await request(app)
        .get('/api/methods')
        .query({ page: 1, pageSize: 5 });

      expect(response.status).toBe(200);
      expect(response.body.data.list.length).toBeLessThanOrEqual(5);
    });
  });

  describe('GET /api/methods/:id', () => {
    it('should get method detail by id', async () => {
      const response = await request(app)
        .get('/api/methods/1');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('id');
      expect(response.body.data).toHaveProperty('title');
    });

    it('should return 404 for non-existent method', async () => {
      const response = await request(app)
        .get('/api/methods/99999');

      expect(response.status).toBe(404);
    });
  });
});

describe('API Tests - Admin Management', () => {
  let adminToken: string;

  beforeAll(async () => {
    // 管理员登录获取token
    const response = await request(app)
      .post('/api/admin/login')
      .send({
        username: 'admin',
        password: 'admin123456',
      });

    if (response.body.success) {
      adminToken = response.body.data.token;
    }
  });

  describe('POST /api/admin/login', () => {
    it('should login successfully with correct credentials', async () => {
      const response = await request(app)
        .post('/api/admin/login')
        .send({
          username: 'admin',
          password: 'admin123456',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('token');
    });

    it('should fail with incorrect password', async () => {
      const response = await request(app)
        .post('/api/admin/login')
        .send({
          username: 'admin',
          password: 'wrongpassword',
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /api/admin/users', () => {
    it('should get users list with admin token', async () => {
      const response = await request(app)
        .get('/api/admin/users')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('items');
    });

    it('should fail without admin token', async () => {
      const response = await request(app)
        .get('/api/admin/users');

      expect(response.status).toBe(401);
    });
  });

  describe('GET /api/admin/media', () => {
    it('should get media files list', async () => {
      const response = await request(app)
        .get('/api/admin/media')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('items');
    });
  });
});

describe('Health Check', () => {
  it('should return ok status', async () => {
    const response = await request(app).get('/health');

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('status', 'ok');
    expect(response.body).toHaveProperty('timestamp');
  });
});
import request from 'supertest';
import { app } from '../index';
import { pool } from '../config/database';

describe('API Tests - User Authentication', () => {
  let testUserToken: string;
  let testUserId: number;

  beforeAll(async () => {
    // 等待数据库连接
    await new Promise(resolve => setTimeout(resolve, 1000));
  });

  afterAll(async () => {
    // 清理测试数据
    if (testUserId) {
      await pool.query('DELETE FROM users WHERE id = $1', [testUserId]);
    }
    await pool.end();
  });

  describe('POST /api/auth/register', () => {
    it('should register a new user successfully', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: `test${Date.now()}@example.com`,
          password: 'test123456',
          nickname: 'Test User',
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('token');
      expect(response.body.data.user).toHaveProperty('id');
      expect(response.body.data.user.email).toBeDefined();

      testUserToken = response.body.data.token;
      testUserId = response.body.data.user.id;
    });

    it('should fail with invalid email format', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'invalid-email',
          password: 'test123456',
          nickname: 'Test User',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should fail with short password', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: `test${Date.now()}@example.com`,
          password: '123',
          nickname: 'Test User',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should fail with duplicate email', async () => {
      const email = `test${Date.now()}@example.com`;
      
      // 第一次注册
      await request(app)
        .post('/api/auth/register')
        .send({
          email,
          password: 'test123456',
          nickname: 'Test User',
        });

      // 第二次注册相同邮箱
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email,
          password: 'test123456',
          nickname: 'Test User 2',
        });

      expect(response.status).toBe(409);
      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /api/auth/login', () => {
    const testEmail = `login${Date.now()}@example.com`;
    const testPassword = 'test123456';

    beforeAll(async () => {
      // 创建测试用户
      await request(app)
        .post('/api/auth/register')
        .send({
          email: testEmail,
          password: testPassword,
          nickname: 'Login Test User',
        });
    });

    it('should login successfully with correct credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: testEmail,
          password: testPassword,
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('token');
      expect(response.body.data.user.email).toBe(testEmail);
    });

    it('should fail with incorrect password', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: testEmail,
          password: 'wrongpassword',
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });

    it('should fail with non-existent email', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'nonexistent@example.com',
          password: testPassword,
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });

    it('should fail with missing credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({});

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /api/auth/me', () => {
    it('should get current user info with valid token', async () => {
      const response = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${testUserToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('id');
      expect(response.body.data).toHaveProperty('email');
    });

    it('should fail without token', async () => {
      const response = await request(app)
        .get('/api/auth/me');

      expect(response.status).toBe(401);
    });

    it('should fail with invalid token', async () => {
      const response = await request(app)
        .get('/api/auth/me')
        .set('Authorization', 'Bearer invalid-token');

      expect(response.status).toBe(401);
    });
  });
});

describe('API Tests - Methods Management', () => {
  describe('GET /api/methods', () => {
    it('should get methods list without authentication', async () => {
      const response = await request(app)
        .get('/api/methods')
        .query({ page: 1, pageSize: 10 });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('list');
      expect(response.body.data).toHaveProperty('total');
      expect(Array.isArray(response.body.data.list)).toBe(true);
    });

    it('should filter methods by category', async () => {
      const response = await request(app)
        .get('/api/methods')
        .query({ category: '放松技巧' });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should support pagination', async () => {
      const response = await request(app)
        .get('/api/methods')
        .query({ page: 1, pageSize: 5 });

      expect(response.status).toBe(200);
      expect(response.body.data.list.length).toBeLessThanOrEqual(5);
    });
  });

  describe('GET /api/methods/:id', () => {
    it('should get method detail by id', async () => {
      const response = await request(app)
        .get('/api/methods/1');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('id');
      expect(response.body.data).toHaveProperty('title');
    });

    it('should return 404 for non-existent method', async () => {
      const response = await request(app)
        .get('/api/methods/99999');

      expect(response.status).toBe(404);
    });
  });
});

describe('API Tests - Admin Management', () => {
  let adminToken: string;

  beforeAll(async () => {
    // 管理员登录获取token
    const response = await request(app)
      .post('/api/admin/login')
      .send({
        username: 'admin',
        password: 'admin123456',
      });

    if (response.body.success) {
      adminToken = response.body.data.token;
    }
  });

  describe('POST /api/admin/login', () => {
    it('should login successfully with correct credentials', async () => {
      const response = await request(app)
        .post('/api/admin/login')
        .send({
          username: 'admin',
          password: 'admin123456',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('token');
    });

    it('should fail with incorrect password', async () => {
      const response = await request(app)
        .post('/api/admin/login')
        .send({
          username: 'admin',
          password: 'wrongpassword',
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /api/admin/users', () => {
    it('should get users list with admin token', async () => {
      const response = await request(app)
        .get('/api/admin/users')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('items');
    });

    it('should fail without admin token', async () => {
      const response = await request(app)
        .get('/api/admin/users');

      expect(response.status).toBe(401);
    });
  });

  describe('GET /api/admin/media', () => {
    it('should get media files list', async () => {
      const response = await request(app)
        .get('/api/admin/media')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('items');
    });
  });
});

describe('Health Check', () => {
  it('should return ok status', async () => {
    const response = await request(app).get('/health');

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('status', 'ok');
    expect(response.body).toHaveProperty('timestamp');
  });
});
