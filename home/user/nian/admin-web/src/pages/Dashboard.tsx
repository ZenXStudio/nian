import React, { useState, useEffect } from 'react'
import { Card, Row, Col, Statistic, Spin } from 'antd'
import {
  UserOutlined,
  FileTextOutlined,
  CheckCircleOutlined,
  EyeOutlined,
} from '@ant-design/icons'
import { getAdminStats } from '../services/api'

const Dashboard: React.FC = () => {
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState<any>({})

  useEffect(() => {
    loadStats()
  }, [])

  const loadStats = async () => {
    try {
      const response: any = await getAdminStats()
      setStats(response.data)
    } catch (error) {
      console.error('Failed to load stats:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return <Spin size="large" style={{ display: 'block', margin: '100px auto' }} />
  }

  return (
    <div>
      <h2 style={{ marginBottom: 24 }}>数据概览</h2>
      <Row gutter={16}>
        <Col span={6}>
          <Card>
            <Statistic
              title="总用户数"
              value={stats.totalUsers || 0}
              prefix={<UserOutlined />}
              valueStyle={{ color: '#3f8600' }}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="总方法数"
              value={stats.totalMethods || 0}
              prefix={<FileTextOutlined />}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="待审核方法"
              value={stats.pendingMethods || 0}
              prefix={<CheckCircleOutlined />}
              valueStyle={{ color: '#cf1322' }}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="总练习记录"
              value={stats.totalPractices || 0}
              prefix={<EyeOutlined />}
              valueStyle={{ color: '#722ed1' }}
            />
          </Card>
        </Col>
      </Row>

      <Row gutter={16} style={{ marginTop: 16 }}>
        <Col span={12}>
          <Card title="方法分类统计">
            {stats.methodsByCategory?.map((item: any) => (
              <div key={item.category} style={{ marginBottom: 8 }}>
                <span>{item.category}: </span>
                <strong>{item.count}</strong>
              </div>
            ))}
          </Card>
        </Col>
        <Col span={12}>
          <Card title="方法难度统计">
            {stats.methodsByDifficulty?.map((item: any) => (
              <div key={item.difficulty} style={{ marginBottom: 8 }}>
                <span>{item.difficulty}: </span>
                <strong>{item.count}</strong>
              </div>
            ))}
          </Card>
        </Col>
      </Row>
    </div>
  )
}

export default Dashboard
