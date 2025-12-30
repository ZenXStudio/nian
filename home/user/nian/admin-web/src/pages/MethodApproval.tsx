import React, { useState, useEffect } from 'react'
import { Table, Button, Space, Modal, message, Tag, Input } from 'antd'
import { CheckOutlined, CloseOutlined } from '@ant-design/icons'
import { getPendingMethods, approveMethod, rejectMethod } from '../services/api'

const { TextArea } = Input

const MethodApproval: React.FC = () => {
  const [loading, setLoading] = useState(false)
  const [methods, setMethods] = useState([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)
  const [selectedMethod, setSelectedMethod] = useState<any>(null)
  const [modalVisible, setModalVisible] = useState(false)
  const [modalType, setModalType] = useState<'approve' | 'reject'>('approve')
  const [comment, setComment] = useState('')

  useEffect(() => {
    loadMethods()
  }, [page, pageSize])

  const loadMethods = async () => {
    setLoading(true)
    try {
      const response: any = await getPendingMethods({
        page,
        page_size: pageSize,
      })
      setMethods(response.data.methods)
      setTotal(response.data.total)
    } catch (error) {
      message.error('加载失败')
    } finally {
      setLoading(false)
    }
  }

  const handleApprove = (record: any) => {
    setSelectedMethod(record)
    setModalType('approve')
    setComment('')
    setModalVisible(true)
  }

  const handleReject = (record: any) => {
    setSelectedMethod(record)
    setModalType('reject')
    setComment('')
    setModalVisible(true)
  }

  const handleModalOk = async () => {
    if (modalType === 'reject' && !comment.trim()) {
      message.warning('请输入拒绝原因')
      return
    }

    try {
      if (modalType === 'approve') {
        await approveMethod(selectedMethod.id, comment)
        message.success('审核通过')
      } else {
        await rejectMethod(selectedMethod.id, comment)
        message.success('已拒绝')
      }
      setModalVisible(false)
      loadMethods()
    } catch (error) {
      message.error('操作失败')
    }
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
      title: '描述',
      dataIndex: 'description',
      ellipsis: true,
    },
    {
      title: '提交时间',
      dataIndex: 'updated_at',
      width: 180,
      render: (text: string) => new Date(text).toLocaleString('zh-CN'),
    },
    {
      title: '操作',
      key: 'action',
      width: 180,
      render: (_: any, record: any) => (
        <Space>
          <Button
            type="primary"
            size="small"
            icon={<CheckOutlined />}
            onClick={() => handleApprove(record)}
          >
            通过
          </Button>
          <Button
            danger
            size="small"
            icon={<CloseOutlined />}
            onClick={() => handleReject(record)}
          >
            拒绝
          </Button>
        </Space>
      ),
    },
  ]

  return (
    <div>
      <h2 style={{ marginBottom: 16 }}>待审核方法</h2>
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
        expandable={{
          expandedRowRender: (record) => (
            <div className="method-content-preview">
              <strong>内容预览：</strong>
              <pre>{JSON.stringify(record.content_json, null, 2)}</pre>
            </div>
          ),
        }}
      />

      <Modal
        title={modalType === 'approve' ? '审核通过' : '审核拒绝'}
        open={modalVisible}
        onOk={handleModalOk}
        onCancel={() => setModalVisible(false)}
      >
        <p>
          <strong>方法标题：</strong>
          {selectedMethod?.title}
        </p>
        <TextArea
          rows={4}
          placeholder={modalType === 'approve' ? '审核意见（可选）' : '请输入拒绝原因（必填）'}
          value={comment}
          onChange={(e) => setComment(e.target.value)}
        />
      </Modal>
    </div>
  )
}

export default MethodApproval
import React, { useState, useEffect } from 'react'
import { Table, Button, Space, Modal, message, Tag, Input } from 'antd'
import { CheckOutlined, CloseOutlined } from '@ant-design/icons'
import { getPendingMethods, approveMethod, rejectMethod } from '../services/api'

const { TextArea } = Input

const MethodApproval: React.FC = () => {
  const [loading, setLoading] = useState(false)
  const [methods, setMethods] = useState([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)
  const [selectedMethod, setSelectedMethod] = useState<any>(null)
  const [modalVisible, setModalVisible] = useState(false)
  const [modalType, setModalType] = useState<'approve' | 'reject'>('approve')
  const [comment, setComment] = useState('')

  useEffect(() => {
    loadMethods()
  }, [page, pageSize])

  const loadMethods = async () => {
    setLoading(true)
    try {
      const response: any = await getPendingMethods({
        page,
        page_size: pageSize,
      })
      setMethods(response.data.methods)
      setTotal(response.data.total)
    } catch (error) {
      message.error('加载失败')
    } finally {
      setLoading(false)
    }
  }

  const handleApprove = (record: any) => {
    setSelectedMethod(record)
    setModalType('approve')
    setComment('')
    setModalVisible(true)
  }

  const handleReject = (record: any) => {
    setSelectedMethod(record)
    setModalType('reject')
    setComment('')
    setModalVisible(true)
  }

  const handleModalOk = async () => {
    if (modalType === 'reject' && !comment.trim()) {
      message.warning('请输入拒绝原因')
      return
    }

    try {
      if (modalType === 'approve') {
        await approveMethod(selectedMethod.id, comment)
        message.success('审核通过')
      } else {
        await rejectMethod(selectedMethod.id, comment)
        message.success('已拒绝')
      }
      setModalVisible(false)
      loadMethods()
    } catch (error) {
      message.error('操作失败')
    }
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
      title: '描述',
      dataIndex: 'description',
      ellipsis: true,
    },
    {
      title: '提交时间',
      dataIndex: 'updated_at',
      width: 180,
      render: (text: string) => new Date(text).toLocaleString('zh-CN'),
    },
    {
      title: '操作',
      key: 'action',
      width: 180,
      render: (_: any, record: any) => (
        <Space>
          <Button
            type="primary"
            size="small"
            icon={<CheckOutlined />}
            onClick={() => handleApprove(record)}
          >
            通过
          </Button>
          <Button
            danger
            size="small"
            icon={<CloseOutlined />}
            onClick={() => handleReject(record)}
          >
            拒绝
          </Button>
        </Space>
      ),
    },
  ]

  return (
    <div>
      <h2 style={{ marginBottom: 16 }}>待审核方法</h2>
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
        expandable={{
          expandedRowRender: (record) => (
            <div className="method-content-preview">
              <strong>内容预览：</strong>
              <pre>{JSON.stringify(record.content_json, null, 2)}</pre>
            </div>
          ),
        }}
      />

      <Modal
        title={modalType === 'approve' ? '审核通过' : '审核拒绝'}
        open={modalVisible}
        onOk={handleModalOk}
        onCancel={() => setModalVisible(false)}
      >
        <p>
          <strong>方法标题：</strong>
          {selectedMethod?.title}
        </p>
        <TextArea
          rows={4}
          placeholder={modalType === 'approve' ? '审核意见（可选）' : '请输入拒绝原因（必填）'}
          value={comment}
          onChange={(e) => setComment(e.target.value)}
        />
      </Modal>
    </div>
  )
}

export default MethodApproval
