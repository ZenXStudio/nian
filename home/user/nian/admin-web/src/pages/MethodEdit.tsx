import React, { useState, useEffect } from 'react'
import { Form, Input, Select, Button, message, InputNumber, Card, Spin } from 'antd'
import { useNavigate, useParams } from 'react-router-dom'
import { createMethod, updateMethod, getMethodById } from '../services/api'

const { TextArea } = Input
const { Option } = Select

const MethodEdit: React.FC = () => {
  const [form] = Form.useForm()
  const [loading, setLoading] = useState(false)
  const [fetching, setFetching] = useState(false)
  const navigate = useNavigate()
  const { id } = useParams()
  const isEdit = !!id

  useEffect(() => {
    if (isEdit) {
      loadMethod()
    }
  }, [id])

  const loadMethod = async () => {
    setFetching(true)
    try {
      const response: any = await getMethodById(Number(id))
      const method = response.data
      form.setFieldsValue({
        title: method.title,
        category: method.category,
        difficulty: method.difficulty,
        duration: method.duration,
        description: method.description,
        content: JSON.stringify(method.content_json, null, 2),
        status: method.status,
      })
    } catch (error) {
      message.error('加载失败')
    } finally {
      setFetching(false)
    }
  }

  const onFinish = async (values: any) => {
    setLoading(true)
    try {
      // 解析 JSON 内容
      let contentJson
      try {
        contentJson = JSON.parse(values.content)
      } catch (e) {
        message.error('内容格式错误，请输入有效的 JSON')
        setLoading(false)
        return
      }

      const data = {
        title: values.title,
        category: values.category,
        difficulty: values.difficulty,
        duration: values.duration,
        description: values.description,
        content_json: contentJson,
        status: values.status || 'draft',
      }

      if (isEdit) {
        await updateMethod(Number(id), data)
        message.success('更新成功')
      } else {
        await createMethod(data)
        message.success('创建成功')
      }
      navigate('/methods')
    } catch (error: any) {
      message.error(error.message || '保存失败')
    } finally {
      setLoading(false)
    }
  }

  if (fetching) {
    return <Spin size="large" style={{ display: 'block', margin: '100px auto' }} />
  }

  return (
    <Card title={isEdit ? '编辑方法' : '新建方法'}>
      <Form
        form={form}
        layout="vertical"
        onFinish={onFinish}
        initialValues={{
          status: 'draft',
          duration: 10,
          content: JSON.stringify({
            steps: [
              { title: '步骤1', description: '描述步骤1的内容' },
              { title: '步骤2', description: '描述步骤2的内容' },
            ],
            tips: ['提示1', '提示2'],
          }, null, 2),
        }}
      >
        <Form.Item
          label="标题"
          name="title"
          rules={[
            { required: true, message: '请输入标题' },
            { max: 50, message: '标题不能超过50个字符' },
          ]}
        >
          <Input placeholder="请输入方法标题" />
        </Form.Item>

        <Form.Item
          label="分类"
          name="category"
          rules={[{ required: true, message: '请选择分类' }]}
        >
          <Select placeholder="请选择分类">
            <Option value="呼吸练习">呼吸练习</Option>
            <Option value="正念冥想">正念冥想</Option>
            <Option value="认知重构">认知重构</Option>
            <Option value="情绪释放">情绪释放</Option>
            <Option value="身体放松">身体放松</Option>
          </Select>
        </Form.Item>

        <Form.Item
          label="难度"
          name="difficulty"
          rules={[{ required: true, message: '请选择难度' }]}
        >
          <Select placeholder="请选择难度">
            <Option value="初级">初级</Option>
            <Option value="中级">中级</Option>
            <Option value="高级">高级</Option>
          </Select>
        </Form.Item>

        <Form.Item
          label="时长（分钟）"
          name="duration"
          rules={[{ required: true, message: '请输入时长' }]}
        >
          <InputNumber min={1} max={120} style={{ width: '100%' }} />
        </Form.Item>

        <Form.Item
          label="描述"
          name="description"
          rules={[
            { required: true, message: '请输入描述' },
            { max: 200, message: '描述不能超过200个字符' },
          ]}
        >
          <TextArea rows={3} placeholder="请输入方法描述" />
        </Form.Item>

        <Form.Item
          label="内容（JSON格式）"
          name="content"
          rules={[{ required: true, message: '请输入内容' }]}
          extra="请输入有效的JSON格式内容，包含steps（步骤）和tips（提示）等字段"
        >
          <TextArea rows={10} placeholder='{"steps": [], "tips": []}' />
        </Form.Item>

        <Form.Item
          label="状态"
          name="status"
          rules={[{ required: true, message: '请选择状态' }]}
        >
          <Select placeholder="请选择状态">
            <Option value="draft">草稿</Option>
            <Option value="pending">待审核</Option>
            <Option value="published">已发布</Option>
          </Select>
        </Form.Item>

        <Form.Item>
          <Space>
            <Button type="primary" htmlType="submit" loading={loading}>
              保存
            </Button>
            <Button onClick={() => navigate('/methods')}>
              取消
            </Button>
          </Space>
        </Form.Item>
      </Form>
    </Card>
  )
}

export default MethodEdit
import React, { useState, useEffect } from 'react'
import { Form, Input, Select, Button, message, InputNumber, Card, Spin } from 'antd'
import { useNavigate, useParams } from 'react-router-dom'
import { createMethod, updateMethod, getMethodById } from '../services/api'

const { TextArea } = Input
const { Option } = Select

const MethodEdit: React.FC = () => {
  const [form] = Form.useForm()
  const [loading, setLoading] = useState(false)
  const [fetching, setFetching] = useState(false)
  const navigate = useNavigate()
  const { id } = useParams()
  const isEdit = !!id

  useEffect(() => {
    if (isEdit) {
      loadMethod()
    }
  }, [id])

  const loadMethod = async () => {
    setFetching(true)
    try {
      const response: any = await getMethodById(Number(id))
      const method = response.data
      form.setFieldsValue({
        title: method.title,
        category: method.category,
        difficulty: method.difficulty,
        duration: method.duration,
        description: method.description,
        content: JSON.stringify(method.content_json, null, 2),
        status: method.status,
      })
    } catch (error) {
      message.error('加载失败')
    } finally {
      setFetching(false)
    }
  }

  const onFinish = async (values: any) => {
    setLoading(true)
    try {
      // 解析 JSON 内容
      let contentJson
      try {
        contentJson = JSON.parse(values.content)
      } catch (e) {
        message.error('内容格式错误，请输入有效的 JSON')
        setLoading(false)
        return
      }

      const data = {
        title: values.title,
        category: values.category,
        difficulty: values.difficulty,
        duration: values.duration,
        description: values.description,
        content_json: contentJson,
        status: values.status || 'draft',
      }

      if (isEdit) {
        await updateMethod(Number(id), data)
        message.success('更新成功')
      } else {
        await createMethod(data)
        message.success('创建成功')
      }
      navigate('/methods')
    } catch (error: any) {
      message.error(error.message || '保存失败')
    } finally {
      setLoading(false)
    }
  }

  if (fetching) {
    return <Spin size="large" style={{ display: 'block', margin: '100px auto' }} />
  }

  return (
    <Card title={isEdit ? '编辑方法' : '新建方法'}>
      <Form
        form={form}
        layout="vertical"
        onFinish={onFinish}
        initialValues={{
          status: 'draft',
          duration: 10,
          content: JSON.stringify({
            steps: [
              { title: '步骤1', description: '描述步骤1的内容' },
              { title: '步骤2', description: '描述步骤2的内容' },
            ],
            tips: ['提示1', '提示2'],
          }, null, 2),
        }}
      >
        <Form.Item
          label="标题"
          name="title"
          rules={[
            { required: true, message: '请输入标题' },
            { max: 50, message: '标题不能超过50个字符' },
          ]}
        >
          <Input placeholder="请输入方法标题" />
        </Form.Item>

        <Form.Item
          label="分类"
          name="category"
          rules={[{ required: true, message: '请选择分类' }]}
        >
          <Select placeholder="请选择分类">
            <Option value="呼吸练习">呼吸练习</Option>
            <Option value="正念冥想">正念冥想</Option>
            <Option value="认知重构">认知重构</Option>
            <Option value="情绪释放">情绪释放</Option>
            <Option value="身体放松">身体放松</Option>
          </Select>
        </Form.Item>

        <Form.Item
          label="难度"
          name="difficulty"
          rules={[{ required: true, message: '请选择难度' }]}
        >
          <Select placeholder="请选择难度">
            <Option value="初级">初级</Option>
            <Option value="中级">中级</Option>
            <Option value="高级">高级</Option>
          </Select>
        </Form.Item>

        <Form.Item
          label="时长（分钟）"
          name="duration"
          rules={[{ required: true, message: '请输入时长' }]}
        >
          <InputNumber min={1} max={120} style={{ width: '100%' }} />
        </Form.Item>

        <Form.Item
          label="描述"
          name="description"
          rules={[
            { required: true, message: '请输入描述' },
            { max: 200, message: '描述不能超过200个字符' },
          ]}
        >
          <TextArea rows={3} placeholder="请输入方法描述" />
        </Form.Item>

        <Form.Item
          label="内容（JSON格式）"
          name="content"
          rules={[{ required: true, message: '请输入内容' }]}
          extra="请输入有效的JSON格式内容，包含steps（步骤）和tips（提示）等字段"
        >
          <TextArea rows={10} placeholder='{"steps": [], "tips": []}' />
        </Form.Item>

        <Form.Item
          label="状态"
          name="status"
          rules={[{ required: true, message: '请选择状态' }]}
        >
          <Select placeholder="请选择状态">
            <Option value="draft">草稿</Option>
            <Option value="pending">待审核</Option>
            <Option value="published">已发布</Option>
          </Select>
        </Form.Item>

        <Form.Item>
          <Space>
            <Button type="primary" htmlType="submit" loading={loading}>
              保存
            </Button>
            <Button onClick={() => navigate('/methods')}>
              取消
            </Button>
          </Space>
        </Form.Item>
      </Form>
    </Card>
  )
}

export default MethodEdit
