-- 全平台心理自助应用系统 - 数据库初始化脚本
-- 创建日期: 2024-01-15

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nickname VARCHAR(50),
    avatar_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    last_login_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

-- 心理自助方法表
CREATE TABLE IF NOT EXISTS methods (
    id SERIAL PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    description VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL,
    difficulty VARCHAR(20) NOT NULL,
    duration_minutes INT NOT NULL,
    cover_image_url VARCHAR(255),
    content_json JSONB NOT NULL,
    status VARCHAR(20) DEFAULT 'draft',
    view_count INT DEFAULT 0,
    select_count INT DEFAULT 0,
    created_by INT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    published_at TIMESTAMP
);

CREATE INDEX idx_methods_status ON methods(status);
CREATE INDEX idx_methods_category ON methods(category);
CREATE INDEX idx_methods_difficulty ON methods(difficulty);
CREATE INDEX idx_methods_created_at ON methods(created_at);

-- 用户方法关联表
CREATE TABLE IF NOT EXISTS user_methods (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    method_id INT NOT NULL REFERENCES methods(id) ON DELETE CASCADE,
    selected_at TIMESTAMP DEFAULT NOW(),
    target_count INT DEFAULT 0,
    completed_count INT DEFAULT 0,
    total_duration_minutes INT DEFAULT 0,
    continuous_days INT DEFAULT 0,
    last_practice_at TIMESTAMP,
    is_favorite BOOLEAN DEFAULT FALSE,
    UNIQUE(user_id, method_id)
);

CREATE INDEX idx_user_methods_user_id ON user_methods(user_id);
CREATE INDEX idx_user_methods_method_id ON user_methods(method_id);
CREATE INDEX idx_user_methods_selected_at ON user_methods(selected_at);

-- 练习记录表
CREATE TABLE IF NOT EXISTS practice_records (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    method_id INT NOT NULL REFERENCES methods(id) ON DELETE CASCADE,
    practice_date DATE NOT NULL,
    duration_minutes INT NOT NULL,
    mood_before INT CHECK (mood_before >= 1 AND mood_before <= 10),
    mood_after INT CHECK (mood_after >= 1 AND mood_after <= 10),
    notes TEXT,
    questionnaire_result JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_practice_records_user_id_date ON practice_records(user_id, practice_date);
CREATE INDEX idx_practice_records_user_id_method_id ON practice_records(user_id, method_id);
CREATE INDEX idx_practice_records_created_at ON practice_records(created_at);

-- 提醒设置表
CREATE TABLE IF NOT EXISTS reminder_settings (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    enabled BOOLEAN DEFAULT TRUE,
    reminder_times JSONB NOT NULL,
    reminder_days JSONB NOT NULL,
    notification_type VARCHAR(20) DEFAULT 'all',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_reminder_settings_user_id ON reminder_settings(user_id);

-- 管理员表
CREATE TABLE IF NOT EXISTS admins (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('super_admin', 'content_admin', 'analyst')),
    email VARCHAR(255) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    last_login_at TIMESTAMP
);

CREATE INDEX idx_admins_username ON admins(username);
CREATE INDEX idx_admins_email ON admins(email);

-- 审核记录表
CREATE TABLE IF NOT EXISTS audit_logs (
    id SERIAL PRIMARY KEY,
    method_id INT REFERENCES methods(id) ON DELETE SET NULL,
    admin_id INT REFERENCES admins(id) ON DELETE SET NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('submit', 'approve', 'reject')),
    status_before VARCHAR(20),
    status_after VARCHAR(20),
    comment TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_method_id ON audit_logs(method_id);
CREATE INDEX idx_audit_logs_admin_id ON audit_logs(admin_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- 媒体文件表
CREATE TABLE IF NOT EXISTS media_files (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(20) NOT NULL CHECK (file_type IN ('image', 'audio', 'video')),
    mime_type VARCHAR(100) NOT NULL,
    file_size BIGINT NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    url VARCHAR(500) NOT NULL,
    uploaded_by INT REFERENCES admins(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_media_files_file_type ON media_files(file_type);
CREATE INDEX idx_media_files_uploaded_by ON media_files(uploaded_by);
CREATE INDEX idx_media_files_created_at ON media_files(created_at);

-- 插入默认管理员账号 (密码: admin123456, bcrypt加密)
-- 注意: 这是示例密码，生产环境必须修改
INSERT INTO admins (username, password_hash, role, email) VALUES 
('admin', '$2b$10$YourBcryptHashHere', 'super_admin', 'admin@mental-app.com')
ON CONFLICT (username) DO NOTHING;

-- 插入示例心理自助方法数据
INSERT INTO methods (title, description, category, difficulty, duration_minutes, content_json, status, published_at) VALUES 
(
    '深呼吸放松法',
    '通过控制呼吸节奏，帮助身心放松，缓解紧张和焦虑情绪',
    '放松技巧',
    '入门',
    10,
    '{
        "chapters": [
            {
                "title": "准备阶段",
                "order": 1,
                "contents": [
                    {"type": "text", "data": "找一个安静舒适的地方，以舒适的姿势坐下或躺下。"},
                    {"type": "text", "data": "闭上眼睛，将注意力集中在呼吸上。"}
                ]
            },
            {
                "title": "练习步骤",
                "order": 2,
                "contents": [
                    {"type": "text", "data": "1. 深深吸气，数到4"},
                    {"type": "text", "data": "2. 屏住呼吸，数到4"},
                    {"type": "text", "data": "3. 缓慢呼气，数到6"},
                    {"type": "text", "data": "4. 重复以上步骤5-10分钟"}
                ]
            }
        ],
        "exercises": [
            {
                "title": "呼吸练习",
                "type": "guided",
                "steps": ["吸气4秒", "屏息4秒", "呼气6秒", "重复"]
            }
        ]
    }',
    'published',
    NOW()
),
(
    '正念冥想',
    '培养当下觉察力，观察思绪而不评判，减轻心理压力',
    '放松技巧',
    '进阶',
    20,
    '{
        "chapters": [
            {
                "title": "什么是正念",
                "order": 1,
                "contents": [
                    {"type": "text", "data": "正念是一种有意识地、不加评判地关注当下的心理状态。"}
                ]
            },
            {
                "title": "练习方法",
                "order": 2,
                "contents": [
                    {"type": "text", "data": "坐直，闭眼，专注于呼吸的感觉。"},
                    {"type": "text", "data": "当思绪飘走时，温柔地将注意力带回呼吸。"}
                ]
            }
        ]
    }',
    'published',
    NOW()
),
(
    '认知重构',
    '识别并改变消极思维模式，建立更积极健康的思维方式',
    '认知调整',
    '进阶',
    15,
    '{
        "chapters": [
            {
                "title": "认识认知扭曲",
                "order": 1,
                "contents": [
                    {"type": "text", "data": "认知扭曲是指不准确或过度负面的思维模式。"}
                ]
            },
            {
                "title": "改变思维",
                "order": 2,
                "contents": [
                    {"type": "text", "data": "1. 识别消极想法"},
                    {"type": "text", "data": "2. 检验这个想法的证据"},
                    {"type": "text", "data": "3. 形成更平衡的观点"}
                ]
            }
        ]
    }',
    'published',
    NOW()
),
(
    '情绪日记',
    '记录每日情绪变化，识别情绪触发因素，提高情绪觉察能力',
    '情绪管理',
    '入门',
    10,
    '{
        "chapters": [
            {
                "title": "如何记录",
                "order": 1,
                "contents": [
                    {"type": "text", "data": "每天花10分钟记录你的情绪和想法。"},
                    {"type": "text", "data": "包括：发生了什么、你的感受、你的想法。"}
                ]
            }
        ],
        "questionnaires": [
            {
                "title": "情绪评估",
                "questions": [
                    {"question": "今天的整体心情如何？", "type": "scale", "options": [1,2,3,4,5,6,7,8,9,10]},
                    {"question": "今天有什么让你开心的事？", "type": "text"},
                    {"question": "今天有什么困扰你的事？", "type": "text"}
                ]
            }
        ]
    }',
    'published',
    NOW()
),
(
    '渐进式肌肉放松',
    '通过有意识地收紧和放松肌肉群，释放身体紧张',
    '放松技巧',
    '入门',
    15,
    '{
        "chapters": [
            {
                "title": "练习步骤",
                "order": 1,
                "contents": [
                    {"type": "text", "data": "从脚部开始，逐步向上到头部。"},
                    {"type": "text", "data": "每个肌肉群收紧5秒，然后放松10秒。"}
                ]
            }
        ]
    }',
    'published',
    NOW()
)
ON CONFLICT DO NOTHING;

-- 创建更新时间自动触发器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_methods_updated_at BEFORE UPDATE ON methods
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reminder_settings_updated_at BEFORE UPDATE ON reminder_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 创建视图: 用户练习统计
CREATE OR REPLACE VIEW user_practice_stats AS
SELECT 
    u.id AS user_id,
    u.email,
    COUNT(DISTINCT pr.id) AS total_practices,
    COALESCE(SUM(pr.duration_minutes), 0) AS total_duration,
    COUNT(DISTINCT pr.practice_date) AS practice_days,
    COALESCE(AVG(pr.mood_after - pr.mood_before), 0) AS avg_mood_improvement
FROM users u
LEFT JOIN practice_records pr ON u.id = pr.user_id
GROUP BY u.id, u.email;

-- 创建视图: 方法热度统计
CREATE OR REPLACE VIEW method_popularity AS
SELECT 
    m.id,
    m.title,
    m.category,
    m.view_count,
    m.select_count,
    COUNT(DISTINCT um.user_id) AS unique_users,
    COUNT(DISTINCT pr.id) AS total_practices,
    COALESCE(AVG(pr.mood_after - pr.mood_before), 0) AS avg_effectiveness
FROM methods m
LEFT JOIN user_methods um ON m.id = um.method_id
LEFT JOIN practice_records pr ON m.id = pr.method_id
WHERE m.status = 'published'
GROUP BY m.id, m.title, m.category, m.view_count, m.select_count
ORDER BY m.select_count DESC;

-- 完成
SELECT 'Database initialization completed successfully!' AS status;
