const express = require('express');
const { Pool } = require('pg');
const path = require('path');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cookieParser = require('cookie-parser');
const session = require('express-session');

const app = express();
const PORT = process.env.PORT || 8010;
const JWT_SECRET = process.env.JWT_SECRET || 'booktaco-secret-key-change-in-production';

// CORS와 JSON 파싱 미들웨어
app.use(cors({ credentials: true, origin: true }));
app.use(express.json());
app.use(cookieParser());
app.use(session({
    secret: JWT_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: {
        secure: false, // 개발 환경에서는 false, 프로덕션에서는 true
        httpOnly: true,
        maxAge: 24 * 60 * 60 * 1000 // 24시간
    }
}));
app.use(express.static('public'));
// 책 이미지 서빙
app.use('/bookimg', express.static('public/bookimg'));

// PostgreSQL 연결 설정
const pool = new Pool({
    user: process.env.DB_USER || 'turtle_user',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'readingturtle',
    password: process.env.DB_PASSWORD || 'ares82',
    port: process.env.DB_PORT || 5432,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
});

// 데이터베이스 연결 테스트
async function testConnection() {
    try {
        const client = await pool.connect();
        console.log('✅ PostgreSQL 데이터베이스 연결 성공');

        // 테이블 존재 확인
        const tableCheck = await client.query(`
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public'
            AND table_name IN ('books', 'quizzes', 'quiz_questions', 'users', 'reading_history')
        `);

        console.log('📋 존재하는 테이블:', tableCheck.rows.map(row => row.table_name));

        client.release();
    } catch (err) {
        console.error('❌ PostgreSQL 연결 실패:', err.message);
        console.log('💡 연결 정보를 확인해주세요:');
        console.log('   - DB_HOST:', process.env.DB_HOST || 'localhost');
        console.log('   - DB_PORT:', process.env.DB_PORT || 5432);
        console.log('   - DB_NAME:', process.env.DB_NAME || 'booktaco');
        console.log('   - DB_USER:', process.env.DB_USER || 'postgres');
    }
}

// ============================================
// 인증 미들웨어
// ============================================

// JWT 인증 미들웨어
function authenticateToken(req, res, next) {
    const token = req.cookies.token || req.headers['authorization']?.split(' ')[1];

    if (!token) {
        return res.status(401).json({
            success: false,
            message: '인증이 필요합니다.'
        });
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        return res.status(403).json({
            success: false,
            message: '유효하지 않은 토큰입니다.'
        });
    }
}

// 선택적 인증 미들웨어 (로그인 선택)
function optionalAuth(req, res, next) {
    const token = req.cookies.token || req.headers['authorization']?.split(' ')[1];

    if (token) {
        try {
            const decoded = jwt.verify(token, JWT_SECRET);
            req.user = decoded;
        } catch (error) {
            // 토큰이 유효하지 않아도 계속 진행
        }
    }
    next();
}

// ============================================
// 인증 관련 API
// ============================================

// 회원가입
app.post('/api/auth/register', async (req, res) => {
    try {
        const { username, email, password, fullName } = req.body;

        // 입력 검증
        if (!username || !email || !password) {
            return res.status(400).json({
                success: false,
                message: '사용자명, 이메일, 비밀번호는 필수입니다.'
            });
        }

        // 비밀번호 길이 검증
        if (password.length < 6) {
            return res.status(400).json({
                success: false,
                message: '비밀번호는 최소 6자 이상이어야 합니다.'
            });
        }

        const client = await pool.connect();

        // 중복 확인
        const existingUser = await client.query(
            'SELECT user_id FROM users WHERE username = $1 OR email = $2',
            [username, email]
        );

        if (existingUser.rows.length > 0) {
            client.release();
            return res.status(400).json({
                success: false,
                message: '이미 존재하는 사용자명 또는 이메일입니다.'
            });
        }

        // 비밀번호 해싱
        const passwordHash = await bcrypt.hash(password, 10);

        // 사용자 생성
        const result = await client.query(
            `INSERT INTO users (username, email, password_hash, full_name)
             VALUES ($1, $2, $3, $4)
             RETURNING user_id, username, email, full_name, created_at`,
            [username, email, passwordHash, fullName || null]
        );

        client.release();

        const user = result.rows[0];

        // JWT 토큰 생성
        const token = jwt.sign(
            { userId: user.user_id, username: user.username },
            JWT_SECRET,
            { expiresIn: '24h' }
        );

        // 쿠키에 토큰 저장
        res.cookie('token', token, {
            httpOnly: true,
            maxAge: 24 * 60 * 60 * 1000 // 24시간
        });

        res.status(201).json({
            success: true,
            message: '회원가입이 완료되었습니다.',
            user: {
                userId: user.user_id,
                username: user.username,
                email: user.email,
                fullName: user.full_name
            },
            token
        });

    } catch (error) {
        console.error('❌ 회원가입 오류:', error);
        res.status(500).json({
            success: false,
            message: '회원가입 중 오류가 발생했습니다.',
            error: error.message
        });
    }
});

// 로그인
app.post('/api/auth/login', async (req, res) => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            return res.status(400).json({
                success: false,
                message: '사용자명과 비밀번호는 필수입니다.'
            });
        }

        const client = await pool.connect();

        // 사용자 조회
        const result = await client.query(
            `SELECT user_id, username, email, password_hash, full_name, is_active
             FROM users
             WHERE username = $1`,
            [username]
        );

        if (result.rows.length === 0) {
            client.release();
            return res.status(401).json({
                success: false,
                message: '사용자명 또는 비밀번호가 일치하지 않습니다.'
            });
        }

        const user = result.rows[0];

        // 계정 활성화 확인
        if (!user.is_active) {
            client.release();
            return res.status(403).json({
                success: false,
                message: '비활성화된 계정입니다.'
            });
        }

        // 비밀번호 확인
        const isValidPassword = await bcrypt.compare(password, user.password_hash);

        if (!isValidPassword) {
            client.release();
            return res.status(401).json({
                success: false,
                message: '사용자명 또는 비밀번호가 일치하지 않습니다.'
            });
        }

        // 마지막 로그인 시간 업데이트
        await client.query(
            'UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE user_id = $1',
            [user.user_id]
        );

        client.release();

        // JWT 토큰 생성
        const token = jwt.sign(
            { userId: user.user_id, username: user.username },
            JWT_SECRET,
            { expiresIn: '24h' }
        );

        // 쿠키에 토큰 저장
        res.cookie('token', token, {
            httpOnly: true,
            maxAge: 24 * 60 * 60 * 1000 // 24시간
        });

        res.json({
            success: true,
            message: '로그인 성공',
            user: {
                userId: user.user_id,
                username: user.username,
                email: user.email,
                fullName: user.full_name
            },
            token
        });

    } catch (error) {
        console.error('❌ 로그인 오류:', error);
        res.status(500).json({
            success: false,
            message: '로그인 중 오류가 발생했습니다.',
            error: error.message
        });
    }
});

// 로그아웃
app.post('/api/auth/logout', (req, res) => {
    res.clearCookie('token');
    res.json({
        success: true,
        message: '로그아웃 되었습니다.'
    });
});

// 현재 사용자 정보 조회
app.get('/api/auth/me', authenticateToken, async (req, res) => {
    try {
        const client = await pool.connect();

        const result = await client.query(
            `SELECT user_id, username, email, full_name, created_at, last_login
             FROM users
             WHERE user_id = $1`,
            [req.user.userId]
        );

        client.release();

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: '사용자를 찾을 수 없습니다.'
            });
        }

        res.json({
            success: true,
            user: result.rows[0]
        });

    } catch (error) {
        console.error('❌ 사용자 정보 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '사용자 정보를 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// ============================================
// 독서 기록 관리 API
// ============================================

// 독서 상태 업데이트 (시작/진행중/완료)
app.post('/api/reading/status', authenticateToken, async (req, res) => {
    try {
        const { isbn, status } = req.body;
        const userId = req.user.userId;

        // 입력 검증
        if (!isbn || !status) {
            return res.status(400).json({
                success: false,
                message: 'ISBN과 상태는 필수입니다.'
            });
        }

        if (!['started', 'reading', 'completed'].includes(status)) {
            return res.status(400).json({
                success: false,
                message: '유효하지 않은 상태입니다. (started, reading, completed 중 선택)'
            });
        }

        const client = await pool.connect();

        // 책이 존재하는지 확인
        const bookCheck = await client.query(
            'SELECT isbn FROM books WHERE isbn = $1',
            [isbn]
        );

        if (bookCheck.rows.length === 0) {
            client.release();
            return res.status(404).json({
                success: false,
                message: '해당 책을 찾을 수 없습니다.'
            });
        }

        // 기존 기록 확인
        const existingRecord = await client.query(
            'SELECT * FROM reading_history WHERE user_id = $1 AND isbn = $2',
            [userId, isbn]
        );

        let result;
        const now = new Date();

        if (existingRecord.rows.length === 0) {
            // 새로운 기록 생성
            // 'reading' 상태로 처음 시작할 때 started_at 기록
            const startedAt = status === 'reading' ? now : null;
            const completedAt = status === 'completed' ? now : null;

            result = await client.query(
                `INSERT INTO reading_history (user_id, isbn, status, started_at, completed_at)
                 VALUES ($1, $2, $3, $4, $5)
                 RETURNING *`,
                [userId, isbn, status, startedAt, completedAt]
            );
        } else {
            // 기존 기록 업데이트
            const record = existingRecord.rows[0];
            const updateFields = { status };

            // started_at: 'reading' 상태일 때 한번만 설정
            if (status === 'reading' && !record.started_at) {
                updateFields.started_at = now;
            }
            // completed_at: 'completed' 상태로 변경될 때 설정
            if (status === 'completed' && !record.completed_at) {
                updateFields.completed_at = now;
            }

            result = await client.query(
                `UPDATE reading_history
                 SET status = $1,
                     started_at = COALESCE($2, started_at),
                     completed_at = COALESCE($3, completed_at),
                     updated_at = CURRENT_TIMESTAMP
                 WHERE user_id = $4 AND isbn = $5
                 RETURNING *`,
                [status, updateFields.started_at, updateFields.completed_at, userId, isbn]
            );
        }

        client.release();

        res.json({
            success: true,
            message: '독서 상태가 업데이트되었습니다.',
            data: result.rows[0]
        });

    } catch (error) {
        console.error('❌ 독서 상태 업데이트 오류:', error);
        res.status(500).json({
            success: false,
            message: '독서 상태 업데이트에 실패했습니다.',
            error: error.message
        });
    }
});

// 내 독서 기록 조회
app.get('/api/reading/history', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const status = req.query.status; // 선택적 필터

        const client = await pool.connect();

        let query = `
            SELECT rh.*, books.title, books.author, books.series, books.bt_level, books.lexile
            FROM reading_history rh
            JOIN books ON rh.isbn = books.isbn
            WHERE rh.user_id = $1
        `;
        const params = [userId];

        if (status) {
            query += ' AND rh.status = $2';
            params.push(status);
        }

        query += ' ORDER BY rh.updated_at DESC';

        const result = await client.query(query, params);

        // 각 책에 이미지 URL 추가
        result.rows.forEach(record => {
            record.image_url = `/bookimg/${record.isbn}.jpg`;
        });

        client.release();

        res.json({
            success: true,
            data: result.rows,
            count: result.rows.length
        });

    } catch (error) {
        console.error('❌ 독서 기록 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '독서 기록을 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// 특정 책의 독서 상태 조회
app.get('/api/reading/status/:isbn', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const isbn = req.params.isbn;

        const client = await pool.connect();

        const result = await client.query(
            'SELECT * FROM reading_history WHERE user_id = $1 AND isbn = $2',
            [userId, isbn]
        );

        client.release();

        if (result.rows.length === 0) {
            return res.json({
                success: true,
                data: null,
                message: '독서 기록이 없습니다.'
            });
        }

        res.json({
            success: true,
            data: result.rows[0]
        });

    } catch (error) {
        console.error('❌ 독서 상태 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '독서 상태를 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// 독서 통계 조회
app.get('/api/reading/stats', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;

        const client = await pool.connect();

        const stats = await client.query(`
            SELECT
                COUNT(*) FILTER (WHERE status = 'started') as started_count,
                COUNT(*) FILTER (WHERE status = 'reading') as reading_count,
                COUNT(*) FILTER (WHERE status = 'completed') as completed_count,
                COUNT(*) as total_count
            FROM reading_history
            WHERE user_id = $1
        `, [userId]);

        client.release();

        res.json({
            success: true,
            stats: stats.rows[0]
        });

    } catch (error) {
        console.error('❌ 독서 통계 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '독서 통계를 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// ============================================
// Reading Calendar API
// ============================================

// Get reading history for calendar (shows all reading periods)
app.get('/api/reading/calendar', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;

        const client = await pool.connect();

        // Query reading history with book information
        const history = await client.query(`
            SELECT
                rh.history_id,
                rh.isbn,
                rh.status,
                rh.started_at,
                rh.reading_at,
                rh.completed_at,
                b.title,
                b.author,
                b.img,
                b.pages as total_pages
            FROM reading_history rh
            JOIN books b ON rh.isbn = b.isbn
            WHERE rh.user_id = $1
            ORDER BY
                CASE
                    WHEN rh.started_at IS NOT NULL THEN rh.started_at
                    ELSE rh.created_at
                END DESC
        `, [userId]);

        client.release();

        res.json({
            success: true,
            history: history.rows
        });

    } catch (error) {
        console.error('❌ 독서 캘린더 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '독서 캘린더를 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// Add or update a reading session
app.post('/api/reading/session', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { isbn, sessionDate, pagesRead, readingMinutes, notes } = req.body;

        if (!isbn || !sessionDate) {
            return res.status(400).json({
                success: false,
                message: 'isbn과 sessionDate는 필수입니다.'
            });
        }

        const client = await pool.connect();

        // Check if session already exists
        const existing = await client.query(
            'SELECT session_id FROM reading_sessions WHERE user_id = $1 AND isbn = $2 AND session_date = $3',
            [userId, isbn, sessionDate]
        );

        let result;
        if (existing.rows.length > 0) {
            // Update existing session
            result = await client.query(`
                UPDATE reading_sessions
                SET pages_read = $1,
                    reading_minutes = $2,
                    notes = $3,
                    updated_at = CURRENT_TIMESTAMP
                WHERE session_id = $4
                RETURNING *
            `, [pagesRead || 0, readingMinutes || 0, notes || '', existing.rows[0].session_id]);
        } else {
            // Insert new session
            result = await client.query(`
                INSERT INTO reading_sessions (user_id, isbn, session_date, pages_read, reading_minutes, notes)
                VALUES ($1, $2, $3, $4, $5, $6)
                RETURNING *
            `, [userId, isbn, sessionDate, pagesRead || 0, readingMinutes || 0, notes || '']);
        }

        client.release();

        res.json({
            success: true,
            session: result.rows[0],
            message: existing.rows.length > 0 ? '독서 기록이 수정되었습니다.' : '독서 기록이 추가되었습니다.'
        });

    } catch (error) {
        console.error('❌ 독서 세션 저장 오류:', error);
        res.status(500).json({
            success: false,
            message: '독서 기록을 저장하는데 실패했습니다.',
            error: error.message
        });
    }
});

// Delete a reading session
app.delete('/api/reading/session/:sessionId', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { sessionId } = req.params;

        const client = await pool.connect();

        // Verify ownership and delete
        const result = await client.query(
            'DELETE FROM reading_sessions WHERE session_id = $1 AND user_id = $2 RETURNING *',
            [sessionId, userId]
        );

        client.release();

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: '독서 기록을 찾을 수 없습니다.'
            });
        }

        res.json({
            success: true,
            message: '독서 기록이 삭제되었습니다.'
        });

    } catch (error) {
        console.error('❌ 독서 세션 삭제 오류:', error);
        res.status(500).json({
            success: false,
            message: '독서 기록을 삭제하는데 실패했습니다.',
            error: error.message
        });
    }
});

// Get sessions for a specific date
app.get('/api/reading/calendar/date/:date', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { date } = req.params;

        const client = await pool.connect();

        const sessions = await client.query(`
            SELECT
                rs.session_id,
                rs.session_date,
                rs.pages_read,
                rs.reading_minutes,
                rs.notes,
                b.isbn,
                b.title,
                b.author,
                b.img,
                b.pages as total_pages
            FROM reading_sessions rs
            JOIN books b ON rs.isbn = b.isbn
            WHERE rs.user_id = $1
              AND rs.session_date = $2
            ORDER BY rs.session_id DESC
        `, [userId, date]);

        client.release();

        res.json({
            success: true,
            sessions: sessions.rows
        });

    } catch (error) {
        console.error('❌ 날짜별 독서 기록 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '독서 기록을 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// ============================================
// Customer Support Board API
// ============================================

// Helper function to check if user is admin
function isAdmin(username) {
    return username === 'syrikx';
}

// Get all support posts (admin can see all, users see only their own)
app.get('/api/support/posts', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const client = await pool.connect();

        // For now, users see only their posts
        // TODO: Add admin role check to see all posts
        const query = `
            SELECT
                sp.*,
                u.username,
                u.full_name,
                (SELECT COUNT(*) FROM support_replies WHERE post_id = sp.post_id) as reply_count
            FROM support_posts sp
            JOIN users u ON sp.user_id = u.user_id
            WHERE sp.user_id = $1
            ORDER BY sp.created_at DESC
        `;

        const result = await client.query(query, [userId]);
        client.release();

        // Debug: Log data types
        if (result.rows.length > 0) {
            console.log('📋 Support post sample:', {
                post_id: typeof result.rows[0].post_id,
                user_id: typeof result.rows[0].user_id,
                reply_count: typeof result.rows[0].reply_count,
                reply_count_value: result.rows[0].reply_count,
            });
        }

        res.json({
            success: true,
            data: result.rows
        });

    } catch (error) {
        console.error('❌ 고객센터 게시글 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '게시글을 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// Get single support post with replies
app.get('/api/support/posts/:postId', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const postId = req.params.postId;
        const client = await pool.connect();

        // Get current user info to check admin status
        const userQuery = 'SELECT username FROM users WHERE user_id = $1';
        const userResult = await client.query(userQuery, [userId]);
        const currentUsername = userResult.rows[0]?.username;
        const userIsAdmin = isAdmin(currentUsername);

        // Get post (check ownership or admin)
        const postQuery = `
            SELECT
                sp.*,
                u.username,
                u.full_name
            FROM support_posts sp
            JOIN users u ON sp.user_id = u.user_id
            WHERE sp.post_id = $1
        `;

        const postResult = await client.query(postQuery, [postId]);

        if (postResult.rows.length === 0) {
            client.release();
            return res.status(404).json({
                success: false,
                message: '게시글을 찾을 수 없습니다.'
            });
        }

        const post = postResult.rows[0];

        // Check access permission for private posts
        if (post.is_private && post.user_id !== userId && !userIsAdmin) {
            client.release();
            return res.status(403).json({
                success: false,
                message: '비공개 게시글은 작성자와 관리자만 볼 수 있습니다.'
            });
        }

        // Get replies
        const repliesQuery = `
            SELECT
                sr.*,
                u.username,
                u.full_name
            FROM support_replies sr
            JOIN users u ON sr.user_id = u.user_id
            WHERE sr.post_id = $1
            ORDER BY sr.created_at ASC
        `;

        const repliesResult = await client.query(repliesQuery, [postId]);
        client.release();

        res.json({
            success: true,
            data: {
                post: postResult.rows[0],
                replies: repliesResult.rows
            }
        });

    } catch (error) {
        console.error('❌ 고객센터 게시글 상세 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '게시글을 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// Create new support post
app.post('/api/support/posts', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { title, content, isPrivate } = req.body;

        if (!title || !content) {
            return res.status(400).json({
                success: false,
                message: '제목과 내용을 입력해주세요.'
            });
        }

        const client = await pool.connect();

        const query = `
            INSERT INTO support_posts (user_id, title, content, status, is_private)
            VALUES ($1, $2, $3, 'open', $4)
            RETURNING *
        `;

        const result = await client.query(query, [userId, title, content, isPrivate || false]);
        client.release();

        res.json({
            success: true,
            data: result.rows[0]
        });

    } catch (error) {
        console.error('❌ 고객센터 게시글 작성 오류:', error);
        res.status(500).json({
            success: false,
            message: '게시글 작성에 실패했습니다.',
            error: error.message
        });
    }
});

// Update support post
app.put('/api/support/posts/:postId', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const postId = req.params.postId;
        const { title, content, isPrivate } = req.body;

        if (!title || !content) {
            return res.status(400).json({
                success: false,
                message: '제목과 내용을 입력해주세요.'
            });
        }

        const client = await pool.connect();

        // Check ownership
        const checkQuery = 'SELECT user_id FROM support_posts WHERE post_id = $1';
        const checkResult = await client.query(checkQuery, [postId]);

        if (checkResult.rows.length === 0) {
            client.release();
            return res.status(404).json({
                success: false,
                message: '게시글을 찾을 수 없습니다.'
            });
        }

        if (checkResult.rows[0].user_id !== userId) {
            client.release();
            return res.status(403).json({
                success: false,
                message: '수정 권한이 없습니다.'
            });
        }

        const updateQuery = `
            UPDATE support_posts
            SET title = $1, content = $2, is_private = $3
            WHERE post_id = $4
            RETURNING *
        `;

        const result = await client.query(updateQuery, [title, content, isPrivate !== undefined ? isPrivate : false, postId]);
        client.release();

        res.json({
            success: true,
            data: result.rows[0]
        });

    } catch (error) {
        console.error('❌ 고객센터 게시글 수정 오류:', error);
        res.status(500).json({
            success: false,
            message: '게시글 수정에 실패했습니다.',
            error: error.message
        });
    }
});

// Delete support post
app.delete('/api/support/posts/:postId', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const postId = req.params.postId;
        const client = await pool.connect();

        // Check ownership
        const checkQuery = 'SELECT user_id FROM support_posts WHERE post_id = $1';
        const checkResult = await client.query(checkQuery, [postId]);

        if (checkResult.rows.length === 0) {
            client.release();
            return res.status(404).json({
                success: false,
                message: '게시글을 찾을 수 없습니다.'
            });
        }

        if (checkResult.rows[0].user_id !== userId) {
            client.release();
            return res.status(403).json({
                success: false,
                message: '삭제 권한이 없습니다.'
            });
        }

        const deleteQuery = 'DELETE FROM support_posts WHERE post_id = $1';
        await client.query(deleteQuery, [postId]);
        client.release();

        res.json({
            success: true,
            message: '게시글이 삭제되었습니다.'
        });

    } catch (error) {
        console.error('❌ 고객센터 게시글 삭제 오류:', error);
        res.status(500).json({
            success: false,
            message: '게시글 삭제에 실패했습니다.',
            error: error.message
        });
    }
});

// Add reply to support post
app.post('/api/support/posts/:postId/replies', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const postId = req.params.postId;
        const { content } = req.body;

        if (!content) {
            return res.status(400).json({
                success: false,
                message: '댓글 내용을 입력해주세요.'
            });
        }

        const client = await pool.connect();

        // Check if post exists
        const checkQuery = 'SELECT post_id FROM support_posts WHERE post_id = $1';
        const checkResult = await client.query(checkQuery, [postId]);

        if (checkResult.rows.length === 0) {
            client.release();
            return res.status(404).json({
                success: false,
                message: '게시글을 찾을 수 없습니다.'
            });
        }

        // Insert reply
        const insertQuery = `
            INSERT INTO support_replies (post_id, user_id, content, is_admin)
            VALUES ($1, $2, $3, false)
            RETURNING *
        `;

        const result = await client.query(insertQuery, [postId, userId, content]);

        // Update post status to 'answered' if reply is from different user
        // For now, we'll keep it simple
        const updateStatusQuery = `
            UPDATE support_posts
            SET status = 'answered'
            WHERE post_id = $1 AND status = 'open'
        `;
        await client.query(updateStatusQuery, [postId]);

        client.release();

        res.json({
            success: true,
            data: result.rows[0]
        });

    } catch (error) {
        console.error('❌ 고객센터 댓글 작성 오류:', error);
        res.status(500).json({
            success: false,
            message: '댓글 작성에 실패했습니다.',
            error: error.message
        });
    }
});

// ============================================
// User Word Study Progress API
// ============================================

// 1. Get user's word progress for a specific book
app.get('/api/user-words/progress/:isbn', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const isbn = req.params.isbn;

        const client = await pool.connect();

        // Get all words for the book with user progress
        // word_lists has the words for each book, word_definitions has definitions
        const query = `
            SELECT
                wl.wordlist_id as word_id,
                wl.word,
                COALESCE(wsp.is_known, false) as is_known,
                COALESCE(wsp.is_bookmarked, false) as is_bookmarked,
                wsp.last_studied_at,
                COALESCE(wsp.study_count, 0) as study_count
            FROM word_lists wl
            LEFT JOIN word_study_progress wsp
                ON wl.word = wsp.word AND wsp.user_id = $1
            WHERE wl.isbn = $2
            ORDER BY wl.word_order
        `;

        const result = await client.query(query, [userId, isbn]);
        client.release();

        res.json({
            success: true,
            data: result.rows
        });

    } catch (error) {
        console.error('❌ 단어 진행 상태 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '단어 진행 상태를 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// 2. Toggle word known status
app.post('/api/user-words/known', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { word_id, is_known } = req.body;

        if (!word_id || is_known === undefined) {
            return res.status(400).json({
                success: false,
                message: 'word_id와 is_known이 필요합니다.'
            });
        }

        const client = await pool.connect();

        // First get the word from word_definitions (word_id from Flutter is from this table)
        const wordResult = await client.query(
            'SELECT word FROM word_definitions WHERE word_id = $1',
            [word_id]
        );

        if (wordResult.rows.length === 0) {
            client.release();
            return res.status(404).json({
                success: false,
                message: '단어를 찾을 수 없습니다.'
            });
        }

        const word = wordResult.rows[0].word;

        // Upsert word progress using word (string) as key
        const query = `
            INSERT INTO word_study_progress (user_id, word, word_id, is_known, last_studied_at, study_count)
            VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP, 0)
            ON CONFLICT (user_id, word)
            DO UPDATE SET
                is_known = $4,
                word_id = $3,
                last_studied_at = CURRENT_TIMESTAMP
            RETURNING word_id, word, is_known, last_studied_at
        `;

        const result = await client.query(query, [userId, word, word_id, is_known]);
        client.release();

        res.json({
            success: true,
            message: '단어 상태가 업데이트되었습니다.',
            data: result.rows[0]
        });

    } catch (error) {
        console.error('❌ 단어 known 상태 업데이트 오류:', error);
        res.status(500).json({
            success: false,
            message: '단어 상태 업데이트에 실패했습니다.',
            error: error.message
        });
    }
});

// 3. Toggle word bookmark
app.post('/api/user-words/bookmark', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { word_id, is_bookmarked } = req.body;

        if (!word_id || is_bookmarked === undefined) {
            return res.status(400).json({
                success: false,
                message: 'word_id와 is_bookmarked가 필요합니다.'
            });
        }

        const client = await pool.connect();

        // First get the word from word_definitions (word_id from Flutter is from this table)
        const wordResult = await client.query(
            'SELECT word FROM word_definitions WHERE word_id = $1',
            [word_id]
        );

        if (wordResult.rows.length === 0) {
            client.release();
            return res.status(404).json({
                success: false,
                message: '단어를 찾을 수 없습니다.'
            });
        }

        const word = wordResult.rows[0].word;

        // Upsert word progress using word (string) as key
        const query = `
            INSERT INTO word_study_progress (user_id, word, word_id, is_bookmarked, last_studied_at, study_count)
            VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP, 0)
            ON CONFLICT (user_id, word)
            DO UPDATE SET
                is_bookmarked = $4,
                word_id = $3,
                last_studied_at = CURRENT_TIMESTAMP
            RETURNING word_id, word, is_bookmarked, last_studied_at
        `;

        const result = await client.query(query, [userId, word, word_id, is_bookmarked]);
        client.release();

        res.json({
            success: true,
            message: '북마크가 업데이트되었습니다.',
            data: result.rows[0]
        });

    } catch (error) {
        console.error('❌ 북마크 업데이트 오류:', error);
        res.status(500).json({
            success: false,
            message: '북마크 업데이트에 실패했습니다.',
            error: error.message
        });
    }
});

// 4. Record word study
app.post('/api/user-words/study', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { word_id } = req.body;

        if (!word_id) {
            return res.status(400).json({
                success: false,
                message: 'word_id가 필요합니다.'
            });
        }

        const client = await pool.connect();

        // First get the word from word_definitions (word_id from Flutter is from this table)
        const wordResult = await client.query(
            'SELECT word FROM word_definitions WHERE word_id = $1',
            [word_id]
        );

        if (wordResult.rows.length === 0) {
            client.release();
            return res.status(404).json({
                success: false,
                message: '단어를 찾을 수 없습니다.'
            });
        }

        const word = wordResult.rows[0].word;

        // Increment study count using word (string) as key
        const query = `
            INSERT INTO word_study_progress (user_id, word, word_id, study_count, last_studied_at)
            VALUES ($1, $2, $3, 1, CURRENT_TIMESTAMP)
            ON CONFLICT (user_id, word)
            DO UPDATE SET
                study_count = word_study_progress.study_count + 1,
                word_id = $3,
                last_studied_at = CURRENT_TIMESTAMP
            RETURNING word_id, word, study_count, last_studied_at
        `;

        const result = await client.query(query, [userId, word, word_id]);
        client.release();

        res.json({
            success: true,
            message: '학습이 기록되었습니다.',
            data: result.rows[0]
        });

    } catch (error) {
        console.error('❌ 학습 기록 오류:', error);
        res.status(500).json({
            success: false,
            message: '학습 기록에 실패했습니다.',
            error: error.message
        });
    }
});

// 5. Get user word statistics
app.get('/api/user-words/stats', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;

        const client = await pool.connect();

        const stats = await client.query(`
            SELECT
                COUNT(DISTINCT word) as total_words,
                COUNT(*) FILTER (WHERE is_known = true) as known_words,
                COUNT(*) FILTER (WHERE is_bookmarked = true) as bookmarked_words,
                COUNT(*) FILTER (WHERE study_count > 0) as studied_words
            FROM word_study_progress
            WHERE user_id = $1
        `, [userId]);

        client.release();

        res.json({
            success: true,
            stats: stats.rows[0]
        });

    } catch (error) {
        console.error('❌ 단어 통계 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '단어 통계를 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// 6. Get all user words (with optional filter)
app.get('/api/user-words/all', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const filterType = req.query.filter; // 'known', 'bookmarked', 'studied'

        const client = await pool.connect();

        let whereClause = 'WHERE wsp.user_id = $1';
        if (filterType === 'known') {
            whereClause += ' AND wsp.is_known = true';
        } else if (filterType === 'bookmarked') {
            whereClause += ' AND wsp.is_bookmarked = true';
        } else if (filterType === 'studied') {
            whereClause += ' AND wsp.study_count > 0';
        }

        const query = `
            SELECT
                wsp.word_id,
                wsp.word,
                wd.definition,
                wsp.is_known,
                wsp.is_bookmarked,
                wsp.study_count,
                wsp.last_studied_at
            FROM word_study_progress wsp
            LEFT JOIN word_definitions wd ON wd.word = wsp.word
            ${whereClause}
            ORDER BY wsp.last_studied_at DESC NULLS LAST
        `;

        const result = await client.query(query, [userId]);
        client.release();

        res.json({
            success: true,
            data: result.rows
        });

    } catch (error) {
        console.error('❌ 사용자 단어 목록 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '단어 목록을 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// 6-1. Get bookmarked words (deprecated, use /all?filter=bookmarked)
app.get('/api/user-words/bookmarked', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;

        const client = await pool.connect();

        const query = `
            SELECT
                wsp.word_id,
                wsp.word,
                wd.definition,
                wsp.is_known,
                wsp.study_count,
                wsp.last_studied_at
            FROM word_study_progress wsp
            LEFT JOIN word_definitions wd ON wd.word = wsp.word
            WHERE wsp.user_id = $1 AND wsp.is_bookmarked = true
            ORDER BY wsp.last_studied_at DESC
        `;

        const result = await client.query(query, [userId]);
        client.release();

        res.json({
            success: true,
            data: result.rows
        });

    } catch (error) {
        console.error('❌ 북마크된 단어 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '북마크된 단어를 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// ============================================
// 기존 도서 API (일부 수정)
// ============================================

// 1. 전체 도서 목록 조회 (페이징 지원)
app.get('/api/books', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 50;
        const offset = (page - 1) * limit;

        const client = await pool.connect();

        // 전체 도서 수 조회
        const countResult = await client.query('SELECT COUNT(*) as total FROM books');
        const totalBooks = parseInt(countResult.rows[0].total);

        // 페이징된 도서 목록 조회
        const booksResult = await client.query(`
            SELECT
                isbn,
                title,
                author,
                series,
                bt_level,
                lexile,
                quiz,
                quiz_url,
                vocab,
                created_at
            FROM books
            ORDER BY created_at DESC
            LIMIT $1 OFFSET $2
        `, [limit, offset]);

        // 각 책에 이미지 URL 추가
        booksResult.rows.forEach(book => {
            book.image_url = `/bookimg/${book.isbn}.jpg`;
        });

        client.release();

        res.json({
            success: true,
            data: booksResult.rows,
            pagination: {
                currentPage: page,
                totalPages: Math.ceil(totalBooks / limit),
                totalBooks: totalBooks,
                limit: limit
            }
        });

    } catch (error) {
        console.error('❌ 도서 목록 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '도서 목록을 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// 2. 도서 검색 (ISBN, 제목, 저자, 시리즈)
app.get('/api/books/search', async (req, res) => {
    try {
        const query = req.query.q;
        const searchType = req.query.type || 'all'; // all, isbn, title, author, series
        const btLevelMin = req.query.btLevelMin ? parseFloat(req.query.btLevelMin) : null;
        const btLevelMax = req.query.btLevelMax ? parseFloat(req.query.btLevelMax) : null;
        const lexileMin = req.query.lexileMin ? parseInt(req.query.lexileMin) : null;
        const lexileMax = req.query.lexileMax ? parseInt(req.query.lexileMax) : null;
        const genre = req.query.genre || 'all'; // all, fiction, nonfiction
        const hasQuiz = req.query.hasQuiz === 'true';
        const hasWords = req.query.hasWords === 'true';
        const levelCondition = req.query.levelCondition || 'AND'; // AND, OR

        if (!query) {
            return res.status(400).json({
                success: false,
                message: '검색어가 필요합니다.'
            });
        }

        const client = await pool.connect();
        let sqlQuery = '';
        let params = [];
        let paramIndex = 1;

        // 레벨 필터 조건 생성
        let levelFilter = '';
        const hasBTLevel = btLevelMin !== null && btLevelMax !== null;
        const hasLexile = lexileMin !== null && lexileMax !== null;

        if (hasBTLevel && hasLexile) {
            if (levelCondition === 'AND') {
                levelFilter += ` AND bt_level BETWEEN $${paramIndex} AND $${paramIndex + 1}`;
                params.push(btLevelMin, btLevelMax);
                paramIndex += 2;
                levelFilter += ` AND CAST(NULLIF(REGEXP_REPLACE(lexile, '[^0-9]', '', 'g'), '') AS INTEGER) BETWEEN $${paramIndex} AND $${paramIndex + 1}`;
                params.push(lexileMin, lexileMax);
                paramIndex += 2;
            } else {
                levelFilter += ` AND (bt_level BETWEEN $${paramIndex} AND $${paramIndex + 1}`;
                params.push(btLevelMin, btLevelMax);
                paramIndex += 2;
                levelFilter += ` OR CAST(NULLIF(REGEXP_REPLACE(lexile, '[^0-9]', '', 'g'), '') AS INTEGER) BETWEEN $${paramIndex} AND $${paramIndex + 1})`;
                params.push(lexileMin, lexileMax);
                paramIndex += 2;
            }
        } else if (hasBTLevel) {
            levelFilter += ` AND bt_level BETWEEN $${paramIndex} AND $${paramIndex + 1}`;
            params.push(btLevelMin, btLevelMax);
            paramIndex += 2;
        } else if (hasLexile) {
            levelFilter += ` AND CAST(NULLIF(REGEXP_REPLACE(lexile, '[^0-9]', '', 'g'), '') AS INTEGER) BETWEEN $${paramIndex} AND $${paramIndex + 1}`;
            params.push(lexileMin, lexileMax);
            paramIndex += 2;
        }

        // 장르 필터
        if (genre !== 'all') {
            if (genre === 'fiction') {
                levelFilter += ` AND type ILIKE $${paramIndex} AND type NOT ILIKE $${paramIndex + 1}`;
                params.push('%fiction%', '%nonfiction%');
                paramIndex += 2;
            } else {
                levelFilter += ` AND type ILIKE $${paramIndex}`;
                params.push(`%${genre}%`);
                paramIndex++;
            }
        }

        // 퀴즈 필터
        if (hasQuiz) {
            levelFilter += ` AND quiz = 1`;
        }

        // 단어 필터
        if (hasWords) {
            levelFilter += ` AND EXISTS (SELECT 1 FROM word_lists wl WHERE wl.isbn = books.isbn)`;
        }

        switch (searchType) {
            case 'isbn':
                sqlQuery = `
                    SELECT
                        isbn, title, author, series, bt_level, lexile, quiz, quiz_url, vocab, created_at,
                        EXISTS (SELECT 1 FROM word_lists wl WHERE wl.isbn = books.isbn) as has_words
                    FROM books
                    WHERE isbn = $${paramIndex}${levelFilter}
                    ORDER BY created_at DESC
                `;
                params.push(query);
                break;

            case 'title':
                sqlQuery = `
                    SELECT
                        isbn, title, author, series, bt_level, lexile, quiz, quiz_url, vocab, created_at,
                        EXISTS (SELECT 1 FROM word_lists wl WHERE wl.isbn = books.isbn) as has_words
                    FROM books
                    WHERE title ILIKE $${paramIndex}${levelFilter}
                    ORDER BY created_at DESC
                    LIMIT 100
                `;
                params.push(`%${query}%`);
                break;

            case 'author':
                sqlQuery = `
                    SELECT
                        isbn, title, author, series, bt_level, lexile, quiz, quiz_url, vocab, created_at,
                        EXISTS (SELECT 1 FROM word_lists wl WHERE wl.isbn = books.isbn) as has_words
                    FROM books
                    WHERE author ILIKE $${paramIndex}${levelFilter}
                    ORDER BY created_at DESC
                    LIMIT 100
                `;
                params.push(`%${query}%`);
                break;

            case 'series':
                sqlQuery = `
                    SELECT
                        isbn, title, author, series, bt_level, lexile, quiz, quiz_url, vocab, created_at,
                        EXISTS (SELECT 1 FROM word_lists wl WHERE wl.isbn = books.isbn) as has_words
                    FROM books
                    WHERE series ILIKE $${paramIndex}${levelFilter}
                    ORDER BY created_at DESC
                    LIMIT 100
                `;
                params.push(`%${query}%`);
                break;

            default: // 'all'
                const queryParam1 = paramIndex;
                const queryParam2 = paramIndex + 1;
                sqlQuery = `
                    SELECT
                        isbn, title, author, series, bt_level, lexile, quiz, quiz_url, vocab, created_at,
                        EXISTS (SELECT 1 FROM word_lists wl WHERE wl.isbn = books.isbn) as has_words
                    FROM books
                    WHERE
                        (isbn = $${queryParam1} OR
                        title ILIKE $${queryParam2} OR
                        author ILIKE $${queryParam2} OR
                        series ILIKE $${queryParam2})${levelFilter}
                    ORDER BY
                        CASE WHEN isbn = $${queryParam1} THEN 1 ELSE 2 END,
                        created_at DESC
                    LIMIT 100
                `;
                params.push(query, `%${query}%`);
        }

        const result = await client.query(sqlQuery, params);
        client.release();

        // 각 책에 이미지 URL 추가
        result.rows.forEach(book => {
            book.image_url = `/bookimg/${book.isbn}.jpg`;
        });

        res.json({
            success: true,
            data: result.rows,
            searchQuery: query,
            searchType: searchType,
            resultCount: result.rows.length
        });

    } catch (error) {
        console.error('❌ 도서 검색 오류:', error);
        res.status(500).json({
            success: false,
            message: '도서 검색에 실패했습니다.',
            error: error.message
        });
    }
});

// 검색어 + 필터 카운트 API
app.get('/api/books/search-count', async (req, res) => {
    try {
        const query = req.query.q;
        const searchType = req.query.type || 'all';
        const btLevelMin = req.query.btLevelMin ? parseFloat(req.query.btLevelMin) : null;
        const btLevelMax = req.query.btLevelMax ? parseFloat(req.query.btLevelMax) : null;
        const lexileMin = req.query.lexileMin ? parseInt(req.query.lexileMin) : null;
        const lexileMax = req.query.lexileMax ? parseInt(req.query.lexileMax) : null;
        const genre = req.query.genre || 'all';
        const hasQuiz = req.query.hasQuiz === 'true';
        const levelCondition = req.query.levelCondition || 'AND';

        if (!query) {
            return res.status(400).json({
                success: false,
                message: '검색어가 필요합니다.'
            });
        }

        const client = await pool.connect();
        let params = [];
        let paramIndex = 1;
        let conditions = [];

        // 검색 조건
        switch (searchType) {
            case 'isbn':
                conditions.push(`isbn = $${paramIndex}`);
                params.push(query);
                paramIndex++;
                break;
            case 'title':
                conditions.push(`title ILIKE $${paramIndex}`);
                params.push(`%${query}%`);
                paramIndex++;
                break;
            case 'author':
                conditions.push(`author ILIKE $${paramIndex}`);
                params.push(`%${query}%`);
                paramIndex++;
                break;
            case 'series':
                conditions.push(`series ILIKE $${paramIndex}`);
                params.push(`%${query}%`);
                paramIndex++;
                break;
            default: // 'all'
                conditions.push(`(isbn = $${paramIndex} OR title ILIKE $${paramIndex + 1} OR author ILIKE $${paramIndex + 1} OR series ILIKE $${paramIndex + 1})`);
                params.push(query, `%${query}%`);
                paramIndex += 2;
        }

        // 레벨 필터 조건
        const hasBTLevel = btLevelMin !== null && btLevelMax !== null;
        const hasLexile = lexileMin !== null && lexileMax !== null;

        if (hasBTLevel && hasLexile) {
            if (levelCondition === 'AND') {
                conditions.push(`bt_level BETWEEN $${paramIndex} AND $${paramIndex + 1}`);
                params.push(btLevelMin, btLevelMax);
                paramIndex += 2;
                conditions.push(`CAST(NULLIF(REGEXP_REPLACE(lexile, '[^0-9]', '', 'g'), '') AS INTEGER) BETWEEN $${paramIndex} AND $${paramIndex + 1}`);
                params.push(lexileMin, lexileMax);
                paramIndex += 2;
            } else {
                conditions.push(`(bt_level BETWEEN $${paramIndex} AND $${paramIndex + 1} OR CAST(NULLIF(REGEXP_REPLACE(lexile, '[^0-9]', '', 'g'), '') AS INTEGER) BETWEEN $${paramIndex + 2} AND $${paramIndex + 3})`);
                params.push(btLevelMin, btLevelMax, lexileMin, lexileMax);
                paramIndex += 4;
            }
        } else if (hasBTLevel) {
            conditions.push(`bt_level BETWEEN $${paramIndex} AND $${paramIndex + 1}`);
            params.push(btLevelMin, btLevelMax);
            paramIndex += 2;
        } else if (hasLexile) {
            conditions.push(`CAST(NULLIF(REGEXP_REPLACE(lexile, '[^0-9]', '', 'g'), '') AS INTEGER) BETWEEN $${paramIndex} AND $${paramIndex + 1}`);
            params.push(lexileMin, lexileMax);
            paramIndex += 2;
        }

        // 장르 필터
        if (genre !== 'all') {
            if (genre === 'fiction') {
                conditions.push(`type ILIKE $${paramIndex} AND type NOT ILIKE $${paramIndex + 1}`);
                params.push('%fiction%', '%nonfiction%');
                paramIndex += 2;
            } else {
                conditions.push(`type ILIKE $${paramIndex}`);
                params.push(`%${genre}%`);
                paramIndex++;
            }
        }

        // 퀴즈 필터
        if (hasQuiz) {
            conditions.push('quiz = 1');
        }

        const whereClause = 'WHERE ' + conditions.join(' AND ');
        const sqlQuery = `SELECT COUNT(*) as count FROM books ${whereClause}`;

        const result = await client.query(sqlQuery, params);
        client.release();

        res.json({
            success: true,
            count: parseInt(result.rows[0].count)
        });

    } catch (error) {
        console.error('❌ 검색 카운트 오류:', error);
        res.status(500).json({
            success: false,
            message: '카운트 조회에 실패했습니다.',
            error: error.message
        });
    }
});

// 필터 카운트 API
app.get('/api/books/filter-count', async (req, res) => {
    try {
        const btLevelMin = req.query.btLevelMin ? parseFloat(req.query.btLevelMin) : null;
        const btLevelMax = req.query.btLevelMax ? parseFloat(req.query.btLevelMax) : null;
        const lexileMin = req.query.lexileMin ? parseInt(req.query.lexileMin) : null;
        const lexileMax = req.query.lexileMax ? parseInt(req.query.lexileMax) : null;
        const genre = req.query.genre || 'all';
        const hasQuiz = req.query.hasQuiz === 'true';
        const levelCondition = req.query.levelCondition || 'AND';

        const client = await pool.connect();
        let params = [];
        let paramIndex = 1;
        let conditions = [];

        // 레벨 필터 조건
        const hasBTLevel = btLevelMin !== null && btLevelMax !== null;
        const hasLexile = lexileMin !== null && lexileMax !== null;

        if (hasBTLevel && hasLexile) {
            if (levelCondition === 'AND') {
                conditions.push(`bt_level BETWEEN $${paramIndex} AND $${paramIndex + 1}`);
                params.push(btLevelMin, btLevelMax);
                paramIndex += 2;
                conditions.push(`CAST(NULLIF(REGEXP_REPLACE(lexile, '[^0-9]', '', 'g'), '') AS INTEGER) BETWEEN $${paramIndex} AND $${paramIndex + 1}`);
                params.push(lexileMin, lexileMax);
                paramIndex += 2;
            } else {
                conditions.push(`(bt_level BETWEEN $${paramIndex} AND $${paramIndex + 1} OR CAST(NULLIF(REGEXP_REPLACE(lexile, '[^0-9]', '', 'g'), '') AS INTEGER) BETWEEN $${paramIndex + 2} AND $${paramIndex + 3})`);
                params.push(btLevelMin, btLevelMax, lexileMin, lexileMax);
                paramIndex += 4;
            }
        } else if (hasBTLevel) {
            conditions.push(`bt_level BETWEEN $${paramIndex} AND $${paramIndex + 1}`);
            params.push(btLevelMin, btLevelMax);
            paramIndex += 2;
        } else if (hasLexile) {
            conditions.push(`CAST(NULLIF(REGEXP_REPLACE(lexile, '[^0-9]', '', 'g'), '') AS INTEGER) BETWEEN $${paramIndex} AND $${paramIndex + 1}`);
            params.push(lexileMin, lexileMax);
            paramIndex += 2;
        }

        // 장르 필터
        if (genre !== 'all') {
            if (genre === 'fiction') {
                conditions.push(`type ILIKE $${paramIndex} AND type NOT ILIKE $${paramIndex + 1}`);
                params.push('%fiction%', '%nonfiction%');
                paramIndex += 2;
            } else {
                conditions.push(`type ILIKE $${paramIndex}`);
                params.push(`%${genre}%`);
                paramIndex++;
            }
        }

        // 퀴즈 필터
        if (hasQuiz) {
            conditions.push('quiz = 1');
        }

        const whereClause = conditions.length > 0 ? 'WHERE ' + conditions.join(' AND ') : '';
        const sqlQuery = `SELECT COUNT(*) as count FROM books ${whereClause}`;

        const result = await client.query(sqlQuery, params);
        client.release();

        res.json({
            success: true,
            count: parseInt(result.rows[0].count)
        });

    } catch (error) {
        console.error('❌ 필터 카운트 오류:', error);
        res.status(500).json({
            success: false,
            message: '카운트 조회에 실패했습니다.',
            error: error.message
        });
    }
});

// 필터 조건으로 도서 브라우징 (검색어 없이)
app.get('/api/books/browse', async (req, res) => {
    try {
        const btLevelMin = req.query.btLevelMin ? parseFloat(req.query.btLevelMin) : null;
        const btLevelMax = req.query.btLevelMax ? parseFloat(req.query.btLevelMax) : null;
        const lexileMin = req.query.lexileMin ? parseInt(req.query.lexileMin) : null;
        const lexileMax = req.query.lexileMax ? parseInt(req.query.lexileMax) : null;
        const genre = req.query.genre || 'all';
        const hasQuiz = req.query.hasQuiz === 'true';
        const hasWords = req.query.hasWords === 'true';
        const levelCondition = req.query.levelCondition || 'AND';

        const client = await pool.connect();
        let params = [];
        let paramIndex = 1;
        let conditions = [];

        // 레벨 필터 조건
        const hasBTLevel = btLevelMin !== null && btLevelMax !== null;
        const hasLexile = lexileMin !== null && lexileMax !== null;

        if (hasBTLevel && hasLexile) {
            if (levelCondition === 'AND') {
                conditions.push(`bt_level BETWEEN $${paramIndex} AND $${paramIndex + 1}`);
                params.push(btLevelMin, btLevelMax);
                paramIndex += 2;
                conditions.push(`CAST(NULLIF(REGEXP_REPLACE(lexile, '[^0-9]', '', 'g'), '') AS INTEGER) BETWEEN $${paramIndex} AND $${paramIndex + 1}`);
                params.push(lexileMin, lexileMax);
                paramIndex += 2;
            } else {
                conditions.push(`(bt_level BETWEEN $${paramIndex} AND $${paramIndex + 1} OR CAST(NULLIF(REGEXP_REPLACE(lexile, '[^0-9]', '', 'g'), '') AS INTEGER) BETWEEN $${paramIndex + 2} AND $${paramIndex + 3})`);
                params.push(btLevelMin, btLevelMax, lexileMin, lexileMax);
                paramIndex += 4;
            }
        } else if (hasBTLevel) {
            conditions.push(`bt_level BETWEEN $${paramIndex} AND $${paramIndex + 1}`);
            params.push(btLevelMin, btLevelMax);
            paramIndex += 2;
        } else if (hasLexile) {
            conditions.push(`CAST(NULLIF(REGEXP_REPLACE(lexile, '[^0-9]', '', 'g'), '') AS INTEGER) BETWEEN $${paramIndex} AND $${paramIndex + 1}`);
            params.push(lexileMin, lexileMax);
            paramIndex += 2;
        }

        // 장르 필터
        if (genre !== 'all') {
            if (genre === 'fiction') {
                conditions.push(`type ILIKE $${paramIndex} AND type NOT ILIKE $${paramIndex + 1}`);
                params.push('%fiction%', '%nonfiction%');
                paramIndex += 2;
            } else {
                conditions.push(`type ILIKE $${paramIndex}`);
                params.push(`%${genre}%`);
                paramIndex++;
            }
        }

        // 퀴즈 필터
        if (hasQuiz) {
            conditions.push('quiz = 1');
        }

        // 단어 필터
        if (hasWords) {
            conditions.push('EXISTS (SELECT 1 FROM word_lists wl WHERE wl.isbn = books.isbn)');
        }

        const whereClause = conditions.length > 0 ? 'WHERE ' + conditions.join(' AND ') : '';
        const sqlQuery = `
            SELECT
                isbn,
                title,
                author,
                series,
                bt_level,
                lexile,
                quiz,
                quiz_url,
                vocab,
                created_at,
                EXISTS (SELECT 1 FROM word_lists wl WHERE wl.isbn = books.isbn) as has_words
            FROM books
            ${whereClause}
            ORDER BY created_at DESC
            LIMIT 500
        `;

        const result = await client.query(sqlQuery, params);
        client.release();

        // 각 책에 이미지 URL 추가
        result.rows.forEach(book => {
            book.image_url = `/bookimg/${book.isbn}.jpg`;
        });

        res.json({
            success: true,
            data: result.rows,
            resultCount: result.rows.length
        });

    } catch (error) {
        console.error('❌ 필터 브라우징 오류:', error);
        res.status(500).json({
            success: false,
            message: '도서 조회에 실패했습니다.',
            error: error.message
        });
    }
});

// 3. 특정 도서의 퀴즈 조회 (ISBN 사용)
app.get('/api/books/:isbn/quizzes', async (req, res) => {
    try {
        const isbn = req.params.isbn;

        if (!isbn) {
            return res.status(400).json({
                success: false,
                message: '유효한 ISBN이 필요합니다.'
            });
        }

        const client = await pool.connect();

        // 먼저 도서 정보 확인
        const bookResult = await client.query(`
            SELECT isbn, title, author, series, bt_level, lexile, quiz, quiz_url
            FROM books
            WHERE isbn = $1
        `, [isbn]);

        if (bookResult.rows.length === 0) {
            client.release();
            return res.status(404).json({
                success: false,
                message: '해당 도서를 찾을 수 없습니다.'
            });
        }

        // quizzes 테이블에서 quiz_id 조회
        const quizResult = await client.query(`
            SELECT quiz_id, isbn, title, total_questions
            FROM quizzes
            WHERE isbn = $1
        `, [isbn]);

        if (quizResult.rows.length === 0) {
            client.release();
            return res.json({
                success: true,
                book: bookResult.rows[0],
                quizzes: [],
                totalQuizzes: 0,
                message: '이 도서에 대한 퀴즈가 아직 없습니다.'
            });
        }

        const quiz_id = quizResult.rows[0].quiz_id;

        // quiz_questions 테이블에서 문제 조회
        const questionsResult = await client.query(`
            SELECT
                question_id,
                quiz_id,
                question_number,
                question_text,
                choice_1,
                choice_2,
                choice_3,
                choice_4,
                correct_answer,
                correct_choice_number,
                created_at
            FROM quiz_questions
            WHERE quiz_id = $1
            ORDER BY question_number
        `, [quiz_id]);

        client.release();

        // 책 정보에 이미지 URL 추가
        const book = bookResult.rows[0];
        book.image_url = `/bookimg/${book.isbn}.jpg`;

        res.json({
            success: true,
            book: book,
            quiz: quizResult.rows[0],
            quizzes: questionsResult.rows,
            totalQuizzes: questionsResult.rows.length
        });

    } catch (error) {
        console.error('❌ 퀴즈 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '퀴즈를 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// 4. 통계 정보 조회
app.get('/api/stats', async (req, res) => {
    try {
        const client = await pool.connect();

        // 기본 통계
        const statsQuery = `
            SELECT
                (SELECT COUNT(*) FROM books) as total_books,
                (SELECT COUNT(*) FROM books WHERE quiz = 1) as books_with_quiz,
                (SELECT COUNT(*) FROM quizzes) as total_quizzes,
                (SELECT COUNT(*) FROM quiz_questions) as total_questions,
                (SELECT COUNT(DISTINCT author) FROM books) as unique_authors,
                (SELECT COUNT(DISTINCT series) FROM books WHERE series IS NOT NULL AND series != '') as unique_series,
                (SELECT MIN(bt_level) FROM books WHERE bt_level > 0) as min_bt_level,
                (SELECT MAX(bt_level) FROM books WHERE bt_level > 0) as max_bt_level,
                (SELECT ROUND(AVG(bt_level)::numeric, 2) FROM books WHERE bt_level > 0) as avg_bt_level
        `;

        const statsResult = await client.query(statsQuery);

        // 상위 저자 (Top 10)
        const topAuthorsResult = await client.query(`
            SELECT author, COUNT(*) as book_count
            FROM books
            WHERE author IS NOT NULL AND author != ''
            GROUP BY author
            ORDER BY book_count DESC
            LIMIT 10
        `);

        // 상위 시리즈 (Top 10)
        const topSeriesResult = await client.query(`
            SELECT series, COUNT(*) as book_count
            FROM books
            WHERE series IS NOT NULL AND series != ''
            GROUP BY series
            ORDER BY book_count DESC
            LIMIT 10
        `);

        // BT 레벨 분포
        const btLevelDistResult = await client.query(`
            SELECT
                bt_level,
                COUNT(*) as book_count
            FROM books
            WHERE bt_level > 0
            GROUP BY bt_level
            ORDER BY bt_level
        `);

        client.release();

        res.json({
            success: true,
            stats: statsResult.rows[0],
            topAuthors: topAuthorsResult.rows,
            topSeries: topSeriesResult.rows,
            btLevelDistribution: btLevelDistResult.rows
        });

    } catch (error) {
        console.error('❌ 통계 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '통계 정보를 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// 5. 도서 상세 정보 조회 (ISBN으로)
app.get('/api/books/:isbn', async (req, res) => {
    try {
        const isbn = req.params.isbn;

        if (!isbn) {
            return res.status(400).json({
                success: false,
                message: '유효한 ISBN이 필요합니다.'
            });
        }

        const client = await pool.connect();

        const result = await client.query(`
            SELECT
                isbn,
                title,
                author,
                series,
                bt_level,
                lexile,
                quiz,
                quiz_url,
                vocab,
                created_at
            FROM books
            WHERE isbn = $1
        `, [isbn]);

        client.release();

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: '해당 도서를 찾을 수 없습니다.'
            });
        }

        // 이미지 URL 추가
        const book = result.rows[0];
        book.image_url = `/bookimg/${book.isbn}.jpg`;

        res.json({
            success: true,
            data: book
        });

    } catch (error) {
        console.error('❌ 도서 상세 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '도서 정보를 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// 6. 도서 단어 목록 조회 (ISBN으로)
app.get('/api/books/:isbn/words', async (req, res) => {
    try {
        const isbn = req.params.isbn;

        if (!isbn) {
            return res.status(400).json({
                success: false,
                message: '유효한 ISBN이 필요합니다.'
            });
        }

        const client = await pool.connect();

        // 단어 목록 조회 (정의 및 최소 레벨 포함)
        const result = await client.query(`
            SELECT
                wl.word,
                wl.word_order,
                wd.word_id,
                wd.definition,
                wd.example_sentence,
                wd.min_bt_level,
                wd.min_lexile
            FROM word_lists wl
            LEFT JOIN word_definitions wd ON wl.word = wd.word
            WHERE wl.isbn = $1
            ORDER BY
                COALESCE(wd.min_bt_level, 999) ASC,
                COALESCE(wd.min_lexile, 9999) ASC,
                wl.word_order ASC
        `, [isbn]);

        client.release();

        if (result.rows.length === 0) {
            return res.json({
                success: true,
                message: '해당 도서에 등록된 단어가 없습니다.',
                data: {
                    isbn: isbn,
                    word_count: 0,
                    words: []
                }
            });
        }

        res.json({
            success: true,
            data: {
                isbn: isbn,
                word_count: result.rows.length,
                words: result.rows
            }
        });

    } catch (error) {
        console.error('❌ 단어 목록 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '단어 목록을 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// 난이도별 단어 학습 API
app.get('/api/words/study', async (req, res) => {
    try {
        const {
            sortBy = 'bt_level',
            limit = 50,
            offset = 0,
            btLevelMin,
            btLevelMax,
            lexileMin,
            lexileMax,
            completionFilter = 'all' // 'all', 'completed', 'incomplete'
        } = req.query;

        // 사용자 ID (로그인한 경우)
        const userId = req.user?.userId;

        // sortBy 검증: 'bt_level' 또는 'lexile'만 허용
        if (!['bt_level', 'lexile'].includes(sortBy)) {
            return res.status(400).json({
                success: false,
                message: 'sortBy는 "bt_level" 또는 "lexile"이어야 합니다.'
            });
        }

        const client = await pool.connect();

        // WHERE 조건 구성
        let whereConditions = [];
        let params = [];
        let paramIndex = 1;

        if (sortBy === 'bt_level') {
            if (btLevelMin !== undefined && btLevelMax !== undefined) {
                whereConditions.push(`wd.min_bt_level BETWEEN $${paramIndex} AND $${paramIndex + 1}`);
                params.push(parseFloat(btLevelMin), parseFloat(btLevelMax));
                paramIndex += 2;
            } else {
                whereConditions.push('wd.min_bt_level IS NOT NULL');
            }
        } else {
            if (lexileMin !== undefined && lexileMax !== undefined) {
                whereConditions.push(`wd.min_lexile BETWEEN $${paramIndex} AND $${paramIndex + 1}`);
                params.push(parseInt(lexileMin), parseInt(lexileMax));
                paramIndex += 2;
            } else {
                whereConditions.push('wd.min_lexile IS NOT NULL');
            }
        }

        // JOIN 절 (사용자가 로그인한 경우에만 완료 상태 조인)
        const joinClause = userId
            ? `LEFT JOIN word_study_progress wsp ON wd.word = wsp.word AND wsp.user_id = $${paramIndex}`
            : '';

        // 완료 상태 필터 추가
        if (userId) {
            params.push(userId);  // JOIN에서 사용할 userId
            paramIndex += 1;

            if (completionFilter === 'completed') {
                whereConditions.push(`wsp.completed = true`);
            } else if (completionFilter === 'incomplete') {
                whereConditions.push(`(wsp.word IS NULL OR wsp.completed = false)`);
            }
        }

        const whereClause = whereConditions.length > 0 ? `WHERE ${whereConditions.join(' AND ')}` : '';

        // 정렬 기준에 따라 ORDER BY 절 설정
        const orderByClause = sortBy === 'bt_level'
            ? 'ORDER BY COALESCE(wd.min_bt_level, 999) ASC, COALESCE(wd.min_lexile, 9999) ASC'
            : 'ORDER BY COALESCE(wd.min_lexile, 9999) ASC, COALESCE(wd.min_bt_level, 999) ASC';

        // LIMIT과 OFFSET 파라미터 추가
        params.push(parseInt(limit), parseInt(offset));

        // 단어 목록 조회 (난이도순 정렬, 페이징, 완료 상태 포함)
        const queryText = `
            SELECT
                wd.word_id,
                wd.word,
                wd.definition,
                wd.example_sentence,
                wd.min_bt_level,
                wd.min_lexile
                ${userId ? ', COALESCE(wsp.completed, false) as is_completed' : ''}
            FROM word_definitions wd
            ${joinClause}
            ${whereClause}
            ${orderByClause}
            LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
        `;

        console.log('📝 Study query:', queryText);
        console.log('📝 Params:', params);

        const result = await client.query(queryText, params);

        // 전체 단어 수 조회
        const countParams = params.slice(0, -2); // LIMIT, OFFSET 제외
        const countResult = await client.query(`
            SELECT COUNT(*) as total
            FROM word_definitions wd
            ${joinClause}
            ${whereClause}
        `, countParams);

        client.release();

        res.json({
            success: true,
            data: {
                words: result.rows,
                total: parseInt(countResult.rows[0].total),
                limit: parseInt(limit),
                offset: parseInt(offset),
                sortBy: sortBy
            }
        });

    } catch (error) {
        console.error('❌ 단어 학습 목록 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '단어 목록을 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// 단어 학습 완료 상태 토글 API
app.post('/api/words/study/toggle', authenticateToken, async (req, res) => {
    try {
        const { word, completed } = req.body;
        const userId = req.user.userId; // JWT 토큰의 userId 사용

        if (!word) {
            return res.status(400).json({
                success: false,
                message: '단어를 지정해야 합니다.'
            });
        }

        const client = await pool.connect();

        if (completed) {
            // 완료 상태로 변경 (INSERT OR UPDATE)
            await client.query(`
                INSERT INTO word_study_progress (user_id, word, completed)
                VALUES ($1, $2, true)
                ON CONFLICT (user_id, word)
                DO UPDATE SET completed = true, completed_at = CURRENT_TIMESTAMP
            `, [userId, word]);
        } else {
            // 완료 취소 (DELETE 또는 UPDATE)
            await client.query(`
                DELETE FROM word_study_progress
                WHERE user_id = $1 AND word = $2
            `, [userId, word]);
        }

        client.release();

        res.json({
            success: true,
            data: { word, completed }
        });

    } catch (error) {
        console.error('❌ 단어 학습 상태 업데이트 오류:', error);
        res.status(500).json({
            success: false,
            message: '단어 학습 상태를 업데이트하는데 실패했습니다.',
            error: error.message
        });
    }
});

// 단어 시험 문제 생성 API
app.get('/api/words/quiz', async (req, res) => {
    try {
        const { btLevelMin = 0, btLevelMax = 10, count = 10 } = req.query;

        const client = await pool.connect();

        // 지정된 BT Level 범위의 단어 가져오기 (정의와 예문이 있는 단어만)
        const result = await client.query(`
            SELECT
                word_id,
                word,
                definition,
                example_sentence,
                min_bt_level,
                min_lexile
            FROM word_definitions
            WHERE min_bt_level >= $1
            AND min_bt_level <= $2
            AND definition IS NOT NULL
            AND definition != ''
            AND example_sentence IS NOT NULL
            AND example_sentence != ''
            ORDER BY RANDOM()
            LIMIT $3 * 5
        `, [parseFloat(btLevelMin), parseFloat(btLevelMax), parseInt(count)]);

        client.release();

        if (result.rows.length < parseInt(count) * 5) {
            return res.status(400).json({
                success: false,
                message: '해당 범위에 충분한 단어가 없습니다. 범위를 넓혀주세요.'
            });
        }

        // 문제 생성: 5개씩 묶어서 하나를 정답으로
        const quizzes = [];
        for (let i = 0; i < parseInt(count); i++) {
            const startIdx = i * 5;
            const choices = result.rows.slice(startIdx, startIdx + 5);
            const correctIdx = Math.floor(Math.random() * 5);
            const correctWord = choices[correctIdx];

            quizzes.push({
                questionNumber: i + 1,
                definition: correctWord.definition,
                exampleSentence: correctWord.example_sentence,
                btLevel: correctWord.min_bt_level,
                lexile: correctWord.min_lexile,
                choices: choices.map(w => ({
                    word: w.word,
                    word_id: w.word_id
                })),
                correctAnswer: correctWord.word,
                correctWordId: correctWord.word_id
            });
        }

        res.json({
            success: true,
            data: {
                quizzes: quizzes,
                totalQuestions: quizzes.length,
                btLevelRange: { min: parseFloat(btLevelMin), max: parseFloat(btLevelMax) }
            }
        });

    } catch (error) {
        console.error('❌ 단어 시험 생성 오류:', error);
        res.status(500).json({
            success: false,
            message: '단어 시험을 생성하는데 실패했습니다.',
            error: error.message
        });
    }
});

// ============================================
// Quiz APIs with Filters
// ============================================

// 1. Generate quiz with user word filters (known/bookmarked/studied)
app.get('/api/quiz/user-words', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { filter, count = 10 } = req.query; // filter: 'known', 'bookmarked', 'studied'

        if (!filter || !['known', 'bookmarked', 'studied'].includes(filter)) {
            return res.status(400).json({
                success: false,
                message: 'filter는 known, bookmarked, studied 중 하나여야 합니다.'
            });
        }

        const client = await pool.connect();

        // Build WHERE clause based on filter
        let whereClause = 'wsp.user_id = $1';
        if (filter === 'known') {
            whereClause += ' AND wsp.is_known = true';
        } else if (filter === 'bookmarked') {
            whereClause += ' AND wsp.is_bookmarked = true';
        } else if (filter === 'studied') {
            whereClause += ' AND wsp.study_count > 0';
        }

        // Get user's words that match the filter
        const userWordsQuery = `
            SELECT wd.word_id, wd.word, wd.definition, wd.example_sentence, wd.min_bt_level
            FROM (
                SELECT DISTINCT wsp.word
                FROM word_study_progress wsp
                WHERE ${whereClause}
            ) AS user_words
            JOIN word_definitions wd ON wd.word = user_words.word
            WHERE wd.definition IS NOT NULL
              AND wd.definition != ''
              AND wd.example_sentence IS NOT NULL
              AND wd.example_sentence != ''
            ORDER BY RANDOM()
            LIMIT $2
        `;

        const userWords = await client.query(userWordsQuery, [userId, parseInt(count)]);

        if (userWords.rows.length < parseInt(count)) {
            client.release();
            return res.status(400).json({
                success: false,
                message: `해당 필터에 충분한 단어가 없습니다. (필요: ${count}개, 사용 가능: ${userWords.rows.length}개)`
            });
        }

        // For each question, get 4 random wrong answers
        const quizzes = [];
        for (let i = 0; i < userWords.rows.length; i++) {
            const correctWord = userWords.rows[i];

            // Get 4 random words for wrong answers (excluding the correct one)
            const wrongAnswersQuery = `
                SELECT word_id, word
                FROM word_definitions
                WHERE word_id != $1
                  AND definition IS NOT NULL
                  AND definition != ''
                ORDER BY RANDOM()
                LIMIT 4
            `;
            const wrongAnswers = await client.query(wrongAnswersQuery, [correctWord.word_id]);

            // Combine correct and wrong answers, then shuffle
            const allChoices = [
                { word: correctWord.word, word_id: correctWord.word_id },
                ...wrongAnswers.rows.map(w => ({ word: w.word, word_id: w.word_id }))
            ];

            // Shuffle choices
            for (let j = allChoices.length - 1; j > 0; j--) {
                const k = Math.floor(Math.random() * (j + 1));
                [allChoices[j], allChoices[k]] = [allChoices[k], allChoices[j]];
            }

            quizzes.push({
                questionNumber: i + 1,
                definition: correctWord.definition,
                exampleSentence: correctWord.example_sentence,
                btLevel: correctWord.min_bt_level,
                choices: allChoices,
                correctAnswer: correctWord.word,
                correctWordId: correctWord.word_id
            });
        }

        client.release();

        res.json({
            success: true,
            data: {
                quizzes: quizzes,
                totalQuestions: quizzes.length,
                quizType: 'user_words',
                filterType: filter
            }
        });

    } catch (error) {
        console.error('❌ 사용자 단어 시험 생성 오류:', error);
        res.status(500).json({
            success: false,
            message: '시험을 생성하는데 실패했습니다.',
            error: error.message
        });
    }
});

// 2. Generate quiz for wrong answers
app.get('/api/quiz/wrong-answers', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { count = 10 } = req.query;

        const client = await pool.connect();

        // Get wrong answers
        const wrongAnswersQuery = `
            SELECT wd.word_id, wd.word, wd.definition, wd.example_sentence, wd.min_bt_level, qwa.last_wrong_at
            FROM (
                SELECT DISTINCT ON (word_id) word_id, last_wrong_at
                FROM quiz_wrong_answers
                WHERE user_id = $1
                ORDER BY word_id, last_wrong_at DESC
            ) AS qwa
            JOIN word_definitions wd ON wd.word_id = qwa.word_id
            WHERE wd.definition IS NOT NULL
              AND wd.definition != ''
              AND wd.example_sentence IS NOT NULL
              AND wd.example_sentence != ''
            ORDER BY qwa.last_wrong_at DESC
            LIMIT $2
        `;

        const wrongWords = await client.query(wrongAnswersQuery, [userId, parseInt(count)]);

        if (wrongWords.rows.length === 0) {
            client.release();
            return res.status(400).json({
                success: false,
                message: '오답 노트에 단어가 없습니다.'
            });
        }

        // For each question, get 4 random wrong answers
        const quizzes = [];
        for (let i = 0; i < wrongWords.rows.length; i++) {
            const correctWord = wrongWords.rows[i];

            // Get 4 random words for wrong answers
            const wrongAnswersQuery = `
                SELECT word_id, word
                FROM word_definitions
                WHERE word_id != $1
                  AND definition IS NOT NULL
                  AND definition != ''
                ORDER BY RANDOM()
                LIMIT 4
            `;
            const randomWrongAnswers = await client.query(wrongAnswersQuery, [correctWord.word_id]);

            // Combine and shuffle
            const allChoices = [
                { word: correctWord.word, word_id: correctWord.word_id },
                ...randomWrongAnswers.rows.map(w => ({ word: w.word, word_id: w.word_id }))
            ];

            for (let j = allChoices.length - 1; j > 0; j--) {
                const k = Math.floor(Math.random() * (j + 1));
                [allChoices[j], allChoices[k]] = [allChoices[k], allChoices[j]];
            }

            quizzes.push({
                questionNumber: i + 1,
                definition: correctWord.definition,
                exampleSentence: correctWord.example_sentence,
                btLevel: correctWord.min_bt_level,
                choices: allChoices,
                correctAnswer: correctWord.word,
                correctWordId: correctWord.word_id
            });
        }

        client.release();

        res.json({
            success: true,
            data: {
                quizzes: quizzes,
                totalQuestions: quizzes.length,
                quizType: 'wrong_answers'
            }
        });

    } catch (error) {
        console.error('❌ 오답 시험 생성 오류:', error);
        res.status(500).json({
            success: false,
            message: '오답 시험을 생성하는데 실패했습니다.',
            error: error.message
        });
    }
});

// 3. Record wrong answer
app.post('/api/quiz/wrong-answer', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { word_id, word, quiz_type, quiz_filter_value } = req.body;

        if (!word_id || !word) {
            return res.status(400).json({
                success: false,
                message: 'word_id와 word가 필요합니다.'
            });
        }

        const client = await pool.connect();

        // Upsert wrong answer
        const query = `
            INSERT INTO quiz_wrong_answers (user_id, word_id, word, quiz_type, quiz_filter_value, wrong_count, last_wrong_at)
            VALUES ($1, $2, $3, $4, $5, 1, CURRENT_TIMESTAMP)
            ON CONFLICT (user_id, word_id)
            DO UPDATE SET
                wrong_count = quiz_wrong_answers.wrong_count + 1,
                last_wrong_at = CURRENT_TIMESTAMP,
                quiz_type = $4,
                quiz_filter_value = $5
            RETURNING *
        `;

        const result = await client.query(query, [userId, word_id, word, quiz_type, quiz_filter_value]);
        client.release();

        res.json({
            success: true,
            message: '오답이 기록되었습니다.',
            data: result.rows[0]
        });

    } catch (error) {
        console.error('❌ 오답 기록 오류:', error);
        res.status(500).json({
            success: false,
            message: '오답 기록에 실패했습니다.',
            error: error.message
        });
    }
});

// 4. Get wrong answers list
app.get('/api/quiz/wrong-answers/list', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;

        const client = await pool.connect();

        const query = `
            SELECT
                qwa.id,
                qwa.word_id,
                qwa.word,
                wd.definition,
                qwa.quiz_type,
                qwa.quiz_filter_value,
                qwa.wrong_count,
                qwa.last_wrong_at,
                qwa.created_at
            FROM quiz_wrong_answers qwa
            LEFT JOIN word_definitions wd ON wd.word_id = qwa.word_id
            WHERE qwa.user_id = $1
            ORDER BY qwa.last_wrong_at DESC
        `;

        const result = await client.query(query, [userId]);
        client.release();

        res.json({
            success: true,
            data: result.rows,
            total: result.rows.length
        });

    } catch (error) {
        console.error('❌ 오답 목록 조회 오류:', error);
        res.status(500).json({
            success: false,
            message: '오답 목록을 가져오는데 실패했습니다.',
            error: error.message
        });
    }
});

// 5. Delete wrong answer
app.delete('/api/quiz/wrong-answer/:word_id', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { word_id } = req.params;

        const client = await pool.connect();

        const query = 'DELETE FROM quiz_wrong_answers WHERE user_id = $1 AND word_id = $2';
        const result = await client.query(query, [userId, parseInt(word_id)]);
        client.release();

        if (result.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: '오답을 찾을 수 없습니다.'
            });
        }

        res.json({
            success: true,
            message: '오답이 삭제되었습니다.'
        });

    } catch (error) {
        console.error('❌ 오답 삭제 오류:', error);
        res.status(500).json({
            success: false,
            message: '오답 삭제에 실패했습니다.',
            error: error.message
        });
    }
});

// 메인 페이지 라우트
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// 404 핸들러
app.use('*', (req, res) => {
    res.status(404).json({
        success: false,
        message: '요청하신 페이지를 찾을 수 없습니다.'
    });
});

// 전역 에러 핸들러
app.use((error, req, res, next) => {
    console.error('🚨 서버 오류:', error);
    res.status(500).json({
        success: false,
        message: '서버 내부 오류가 발생했습니다.',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
});

// 서버 시작
app.listen(PORT, async () => {
    console.log('\n🐢 ReadingTurtle 서버 시작됨');
    console.log(`📍 URL: http://localhost:${PORT}`);
    console.log('🗄️  데이터베이스: PostgreSQL (booktaco)');
    console.log('⏰ 시작 시간:', new Date().toLocaleString('ko-KR'));

    // 데이터베이스 연결 테스트
    await testConnection();

    console.log('\n💡 사용 가능한 API:');
    console.log('   GET  /api/books           - 도서 목록 (페이징)');
    console.log('   GET  /api/books/search    - 도서 검색');
    console.log('   GET  /api/books/:isbn     - 도서 상세 정보');
    console.log('   GET  /api/books/:isbn/quizzes - 퀴즈 조회');
    console.log('   GET  /api/stats           - 통계 정보');
    console.log('\n🌐 웹 인터페이스: http://localhost:' + PORT);
});

// Graceful shutdown
process.on('SIGINT', async () => {
    console.log('\n🔄 서버 종료 중...');
    await pool.end();
    console.log('✅ PostgreSQL 연결 풀 종료됨');
    process.exit(0);
});

process.on('SIGTERM', async () => {
    console.log('\n🔄 서버 종료 중...');
    await pool.end();
    console.log('✅ PostgreSQL 연결 풀 종료됨');
    process.exit(0);
});
