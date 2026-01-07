import React, { useState, useEffect } from 'react'
import { Table, Button, Space, Modal, message, Tag, Input } from 'antd'
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons'
import { useNavigate } from 'react-router-dom'
import { getMethods, deleteMethod } from '../services/api'

const { Search } = Input

const MethodList: React.FC = () => {
  const [loading, setLoading] = useState(false)
  const [methods, setMethods] = useState([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)
  const [keyword, setKeyword] = useState('')
  const navigate = useNavigate()

  useEffect(() => {
    loadMethods()
  }, [page, pageSize, keyword])

  const loadMethods = async () => {
    setLoading(true)
    try {
      const response: any = await getMethods({
        page,
        page_size: pageSize,
        keyword: keyword || undefined,
      })
      setMethods(response.data.methods)
      setTotal(response.data.total)
    } catch (error) {
      message.error('加载失败')
    } finally {
      setLoading(false)
    }
  }

  const handleDelete = (id: number) => {
    Modal.confirm({
      title: '确认删除',
      content: '删除后无法恢复，确定要删除这个方法吗？',
      onOk: async () => {
        try {
          await deleteMethod(id)
          message.success('删除成功')
          loadMethods()
        } catch (error) {
          message.error('删除失败')
        }
      },
    })
  }

  const statusMap: any = {
    draft: { text: '草稿', color: 'default' },
    pending: { text: '待审核', color: 'warning' },
    published: { text: '已发布', color: 'success' },
    rejected: { text: '已拒绝', color: 'error' },
  }

  const columns = [
    {
      title: 'ID',
      dataIndex: 'id',
      width: 60,
    },
    {
      title: '标题',
      dataIndex: 'title',
      width: 200,
    },
    {
      title: '分类',
      dataIndex: 'category',
      width: 120,
    },
    {
      title: '难度',
      dataIndex: 'difficulty',
      width: 100,
    },
    {
      title: '时长(分钟)',
      dataIndex: 'duration',
      width: 100,
    },
    {
      title: '状态',
      dataIndex: 'status',
      width: 100,
      render: (status: string) => (
        <Tag color={statusMap[status]?.color}>{statusMap[status]?.text}</Tag>
      ),
    },
    {
      title: '创建时间',
      dataIndex: 'created_at',
      width: 180,
      render: (text: string) => new Date(text).toLocaleString('zh-CN'),
    },
    {
      title: '操作',
      key: 'action',
      width: 150,
      render: (_: any, record: any) => (
        <Space>
          <Button
            type="link"
            icon={<EditOutlined />}
            onClick={() => navigate(`/methods/edit/${record.id}`)}
          >
            编辑
          </Button>
          <Button
            type="link"
            danger
            icon={<DeleteOutlined />}
            onClick={() => handleDelete(record.id)}
          >
            删除
          </Button>
        </Space>
      ),
    },
  ]

  return (
    <div>
      <div style={{ marginBottom: 16, display: 'flex', justifyContent: 'space-between' }}>
        <Button
          type="primary"
          icon={<PlusOutlined />}
          onClick={() => navigate('/methods/new')}
        >
          新建方法
        </Button>
        <Search
          placeholder="搜索标题或描述"
          style={{ width: 300 }}
          onSearch={(value) => {
            setKeyword(value)
            setPage(1)
          }}
          allowClear
        />
      </div>
      <Table
        columns={columns}
        dataSource={methods}
        rowKey="id"
        loading={loading}
        pagination={{
          current: page,
          pageSize: pageSize,
          total: total,
          showSizeChanger: true,
          showTotal: (total) => `共 ${total} 条`,
          onChange: (page, pageSize) => {
            setPage(page)
            setPageSize(pageSize)
          },
        }}
      />
    </div>
  )
}

export default MethodList
import React, { useState, useEffect } from 'react'
import { Table, Button, Space, Modal, message, Tag, Input } from 'antd'
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons'
import { useNavigate } from 'react-router-dom'
import { getMethods, deleteMethod } from '../services/api'

const { Search } = Input

const MethodList: React.FC = () => {
  const [loading, setLoading] = useState(false)
  const [methods, setMethods] = useState([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)
  const [keyword, setKeyword] = useState('')
  const navigate = useNavigate()

  useEffect(() => {
    loadMethods()
  }, [page, pageSize, keyword])

  const loadMethods = async () => {
    setLoading(true)
    try {
      const response: any = await getMethods({
        page,
        page_size: pageSize,
        keyword: keyword || undefined,
      })
      setMethods(response.data.methods)
      setTotal(response.data.total)
    } catch (error) {
      message.error('加载失败')
    } finally {
      setLoading(false)
    }
  }

  const handleDelete = (id: number) => {
    Modal.confirm({
      title: '确认删除',
      content: '删除后无法恢复，确定要删除这个方法吗？',
      onOk: async () => {
        try {
          await deleteMethod(id)
          message.success('删除成功')
          loadMethods()
        } catch (error) {
          message.error('删除失败')
        }
      },
    })
  }

  const statusMap: any = {
    draft: { text: '草稿', color: 'default' },
    pending: { text: '待审核', color: 'warning' },
    published: { text: '已发布', color: 'success' },
    rejected: { text: '已拒绝', color: 'error' },
  }

  const columns = [
    {
      title: 'ID',
      dataIndex: 'id',
      width: 60,
    },
    {
      title: '标题',
      dataIndex: 'title',
      width: 200,
    },
    {
      title: '分类',
      dataIndex: 'category',
      width: 120,
    },
    {
      title: '难度',
      dataIndex: 'difficulty',
      width: 100,
    },
    {
      title: '时长(分钟)',
      dataIndex: 'duration',
      width: 100,
    },
    {
      title: '状态',
      dataIndex: 'status',
      width: 100,
      render: (status: string) => (
        <Tag color={statusMap[status]?.color}>{statusMap[status]?.text}</Tag>
      ),
    },
    {
      title: '创建时间',
      dataIndex: 'created_at',
      width: 180,
      render: (text: string) => new Date(text).toLocaleString('zh-CN'),
    },
    {
      title: '操作',
      key: 'action',
      width: 150,
      render: (_: any, record: any) => (
        <Space>
          <Button
            type="link"
            icon={<EditOutlined />}
            onClick={() => navigate(`/methods/edit/${record.id}`)}
          >
            编辑
          </Button>
          <Button
            type="link"
            danger
            icon={<DeleteOutlined />}
            onClick={() => handleDelete(record.id)}
          >
            删除
          </Button>
        </Space>
      ),
    },
  ]

  return (
    <div>
      <div style={{ marginBottom: 16, display: 'flex', justifyContent: 'space-between' }}>
        <Button
          type="primary"
          icon={<PlusOutlined />}
          onClick={() => navigate('/methods/new')}
        >
          新建方法
        </Button>
        <Search
          placeholder="搜索标题或描述"
          style={{ width: 300 }}
          onSearch={(value) => {
            setKeyword(value)
            setPage(1)
          }}
          allowClear
        />
      </div>
      <Table
        columns={columns}
        dataSource={methods}
        rowKey="id"
        loading={loading}
        pagination={{
          current: page,
          pageSize: pageSize,
          total: total,
          showSizeChanger: true,
          showTotal: (total) => `共 ${total} 条`,
          onChange: (page, pageSize) => {
            setPage(page)
            setPageSize(pageSize)
          },
        }}
      />
    </div>
  )
}

export default MethodList
