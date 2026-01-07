import React, { useState, useEffect } from 'react';
import {
  Table,
  Button,
  Input,
  Select,
  Space,
  Tag,
  Modal,
  message,
  Descriptions,
  Tabs,
  Card,
  Statistic,
  Switch,
  Popconfirm,
} from 'antd';
import {
  UserOutlined,
  SearchOutlined,
  EyeOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
} from '@ant-design/icons';
import { api } from '../services/api';

const { Search } = Input;
const { Option } = Select;
const { TabPane } = Tabs;

interface User {
  id: number;
  email: string;
  nickname: string;
  avatar_url?: string;
  created_at: string;
  last_login_at?: string;
  is_active: boolean;
  method_count: number;
  practice_count: number;
  total_practice_duration?: number;
  avg_mood_improvement?: number;
}

interface UserMethod {
  id: number;
  method_name: string;
  category: string;
  difficulty: string;
  personal_goal?: string;
  is_favorite: boolean;
  selected_at: string;
  practice_count: number;
}

interface PracticeRecord {
  id: number;
  method_name: string;
  practice_date: string;
  duration_minutes: number;
  mood_before: number;
  mood_after: number;
  notes?: string;
}

const UserManagement: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 20,
    total: 0,
  });
  const [filters, setFilters] = useState({
    search: '',
    status: 'all',
    sortBy: 'created_at',
    sortOrder: 'desc',
  });
  const [detailModalVisible, setDetailModalVisible] = useState(false);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [userMethods, setUserMethods] = useState<UserMethod[]>([]);
  const [userPractices, setUserPractices] = useState<PracticeRecord[]>([]);
  const [loadingDetail, setLoadingDetail] = useState(false);

  useEffect(() => {
    fetchUsers();
  }, [pagination.current, pagination.pageSize, filters]);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const response = await api.get('/admin/users', {
        params: {
          search: filters.search,
          status: filters.status,
          page: pagination.current,
          pageSize: pagination.pageSize,
          sortBy: filters.sortBy,
          sortOrder: filters.sortOrder,
        },
      });

      if (response.data.success) {
        setUsers(response.data.data.items);
        setPagination({
          ...pagination,
          total: response.data.data.total,
        });
      }
    } catch (error) {
      message.error('获取用户列表失败');
    } finally {
      setLoading(false);
    }
  };

  const fetchUserDetail = async (userId: number) => {
    setLoadingDetail(true);
    try {
      const [detailRes, methodsRes, practicesRes] = await Promise.all([
        api.get(`/admin/users/${userId}`),
        api.get(`/admin/users/${userId}/methods`),
        api.get(`/admin/users/${userId}/practices`, { params: { pageSize: 10 } }),
      ]);

      if (detailRes.data.success) {
        setSelectedUser(detailRes.data.data);
      }
      if (methodsRes.data.success) {
        setUserMethods(methodsRes.data.data);
      }
      if (practicesRes.data.success) {
        setUserPractices(practicesRes.data.data.items);
      }
    } catch (error) {
      message.error('获取用户详情失败');
    } finally {
      setLoadingDetail(false);
    }
  };

  const handleViewDetail = (user: User) => {
    setSelectedUser(user);
    setDetailModalVisible(true);
    fetchUserDetail(user.id);
  };

  const handleUpdateStatus = async (userId: number, isActive: boolean) => {
    try {
      await api.put(`/admin/users/${userId}/status`, { is_active: isActive });
      message.success('用户状态更新成功');
      fetchUsers();
    } catch (error) {
      message.error('用户状态更新失败');
    }
  };

  const columns = [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
      width: 80,
    },
    {
      title: '邮箱',
      dataIndex: 'email',
      key: 'email',
      ellipsis: true,
    },
    {
      title: '昵称',
      dataIndex: 'nickname',
      key: 'nickname',
      render: (text: string) => text || '-',
    },
    {
      title: '方法数',
      dataIndex: 'method_count',
      key: 'method_count',
      width: 100,
      sorter: true,
    },
    {
      title: '练习次数',
      dataIndex: 'practice_count',
      key: 'practice_count',
      width: 100,
      sorter: true,
    },
    {
      title: '注册时间',
      dataIndex: 'created_at',
      key: 'created_at',
      width: 180,
      render: (date: string) => new Date(date).toLocaleString('zh-CN'),
      sorter: true,
    },
    {
      title: '最后登录',
      dataIndex: 'last_login_at',
      key: 'last_login_at',
      width: 180,
      render: (date: string) => date ? new Date(date).toLocaleString('zh-CN') : '-',
      sorter: true,
    },
    {
      title: '状态',
      dataIndex: 'is_active',
      key: 'is_active',
      width: 100,
      render: (isActive: boolean, record: User) => (
        <Popconfirm
          title={`确定要${isActive ? '禁用' : '激活'}该用户吗？`}
          onConfirm={() => handleUpdateStatus(record.id, !isActive)}
          okText="确定"
          cancelText="取消"
        >
          <Switch checked={isActive} />
        </Popconfirm>
      ),
    },
    {
      title: '操作',
      key: 'action',
      width: 120,
      fixed: 'right' as const,
      render: (_: any, record: User) => (
        <Button
          type="link"
          icon={<EyeOutlined />}
          onClick={() => handleViewDetail(record)}
        >
          详情
        </Button>
      ),
    },
  ];

  const methodColumns = [
    {
      title: '方法名称',
      dataIndex: 'method_name',
      key: 'method_name',
    },
    {
      title: '分类',
      dataIndex: 'category',
      key: 'category',
    },
    {
      title: '难度',
      dataIndex: 'difficulty',
      key: 'difficulty',
    },
    {
      title: '练习次数',
      dataIndex: 'practice_count',
      key: 'practice_count',
    },
    {
      title: '添加时间',
      dataIndex: 'selected_at',
      key: 'selected_at',
      render: (date: string) => new Date(date).toLocaleString('zh-CN'),
    },
    {
      title: '收藏',
      dataIndex: 'is_favorite',
      key: 'is_favorite',
      render: (isFavorite: boolean) =>
        isFavorite ? <Tag color="red">收藏</Tag> : <Tag>未收藏</Tag>,
    },
  ];

  const practiceColumns = [
    {
      title: '方法',
      dataIndex: 'method_name',
      key: 'method_name',
    },
    {
      title: '练习日期',
      dataIndex: 'practice_date',
      key: 'practice_date',
      render: (date: string) => new Date(date).toLocaleDateString('zh-CN'),
    },
    {
      title: '时长(分钟)',
      dataIndex: 'duration_minutes',
      key: 'duration_minutes',
    },
    {
      title: '心情前',
      dataIndex: 'mood_before',
      key: 'mood_before',
    },
    {
      title: '心情后',
      dataIndex: 'mood_after',
      key: 'mood_after',
    },
    {
      title: '改善',
      key: 'improvement',
      render: (_: any, record: PracticeRecord) => {
        const improvement = record.mood_after - record.mood_before;
        return (
          <Tag color={improvement > 0 ? 'green' : improvement < 0 ? 'red' : 'default'}>
            {improvement > 0 ? '+' : ''}{improvement}
          </Tag>
        );
      },
    },
  ];

  return (
    <div style={{ padding: 24 }}>
      <h1>用户管理</h1>

      <Card style={{ marginBottom: 16 }}>
        <Space style={{ marginBottom: 16, width: '100%', justifyContent: 'space-between' }}>
          <Space>
            <Search
              placeholder="搜索邮箱或昵称"
              allowClear
              onSearch={(value) => setFilters({ ...filters, search: value })}
              style={{ width: 300 }}
            />
            <Select
              value={filters.status}
              onChange={(value) => setFilters({ ...filters, status: value })}
              style={{ width: 120 }}
            >
              <Option value="all">全部状态</Option>
              <Option value="active">激活</Option>
              <Option value="inactive">禁用</Option>
            </Select>
            <Select
              value={filters.sortBy}
              onChange={(value) => setFilters({ ...filters, sortBy: value })}
              style={{ width: 150 }}
            >
              <Option value="created_at">注册时间</Option>
              <Option value="last_login_at">最后登录</Option>
              <Option value="method_count">方法数</Option>
              <Option value="practice_count">练习次数</Option>
            </Select>
            <Select
              value={filters.sortOrder}
              onChange={(value) => setFilters({ ...filters, sortOrder: value })}
              style={{ width: 100 }}
            >
              <Option value="desc">降序</Option>
              <Option value="asc">升序</Option>
            </Select>
          </Space>
        </Space>

        <Table
          columns={columns}
          dataSource={users}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1200 }}
          pagination={{
            ...pagination,
            showSizeChanger: true,
            showQuickJumper: true,
            showTotal: (total) => `共 ${total} 个用户`,
            onChange: (page, pageSize) => {
              setPagination({ ...pagination, current: page, pageSize: pageSize || 20 });
            },
          }}
        />
      </Card>

      <Modal
        title="用户详情"
        open={detailModalVisible}
        onCancel={() => setDetailModalVisible(false)}
        footer={null}
        width={1000}
      >
        {selectedUser && (
          <Tabs defaultActiveKey="1">
            <TabPane tab="基本信息" key="1">
              <Card>
                <Descriptions bordered column={2}>
                  <Descriptions.Item label="用户ID">{selectedUser.id}</Descriptions.Item>
                  <Descriptions.Item label="邮箱">{selectedUser.email}</Descriptions.Item>
                  <Descriptions.Item label="昵称">{selectedUser.nickname || '-'}</Descriptions.Item>
                  <Descriptions.Item label="状态">
                    {selectedUser.is_active ? (
                      <Tag icon={<CheckCircleOutlined />} color="success">激活</Tag>
                    ) : (
                      <Tag icon={<CloseCircleOutlined />} color="error">禁用</Tag>
                    )}
                  </Descriptions.Item>
                  <Descriptions.Item label="注册时间">
                    {new Date(selectedUser.created_at).toLocaleString('zh-CN')}
                  </Descriptions.Item>
                  <Descriptions.Item label="最后登录">
                    {selectedUser.last_login_at
                      ? new Date(selectedUser.last_login_at).toLocaleString('zh-CN')
                      : '从未登录'}
                  </Descriptions.Item>
                </Descriptions>

                <div style={{ marginTop: 24 }}>
                  <Space size="large">
                    <Statistic title="方法库数量" value={selectedUser.method_count} prefix={<UserOutlined />} />
                    <Statistic title="练习次数" value={selectedUser.practice_count} />
                    <Statistic
                      title="总练习时长(分钟)"
                      value={selectedUser.total_practice_duration || 0}
                    />
                    <Statistic
                      title="平均心情改善"
                      value={selectedUser.avg_mood_improvement?.toFixed(2) || 0}
                      suffix="/10"
                    />
                  </Space>
                </div>
              </Card>
            </TabPane>

            <TabPane tab={`方法库 (${userMethods.length})`} key="2">
              <Table
                columns={methodColumns}
                dataSource={userMethods}
                rowKey="id"
                loading={loadingDetail}
                pagination={false}
              />
            </TabPane>

            <TabPane tab={`练习记录 (最近10条)`} key="3">
              <Table
                columns={practiceColumns}
                dataSource={userPractices}
                rowKey="id"
                loading={loadingDetail}
                pagination={false}
              />
            </TabPane>
          </Tabs>
        )}
      </Modal>
    </div>
  );
};

export default UserManagement;
