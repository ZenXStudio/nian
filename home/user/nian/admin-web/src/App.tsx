import React, { useState, useEffect } from 'react'
import { Routes, Route, Navigate, useNavigate } from 'react-router-dom'
import { Layout, Menu, Avatar, Dropdown } from 'antd'
import {
  DashboardOutlined,
  FileTextOutlined,
  CheckCircleOutlined,
  UserOutlined,
  LogoutOutlined,
  CloudUploadOutlined,
  ExportOutlined,
  TeamOutlined,
} from '@ant-design/icons'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import MethodList from './pages/MethodList'
import MethodEdit from './pages/MethodEdit'
import MethodApproval from './pages/MethodApproval'
import MediaLibrary from './pages/MediaLibrary'
import DataExport from './pages/DataExport'
import UserManagement from './pages/UserManagement'
import './App.css'

const { Header, Sider, Content } = Layout

const App: React.FC = () => {
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [adminInfo, setAdminInfo] = useState<any>(null)
  const navigate = useNavigate()

  useEffect(() => {
    const token = localStorage.getItem('admin_token')
    const info = localStorage.getItem('admin_info')
    if (token && info) {
      setIsAuthenticated(true)
      setAdminInfo(JSON.parse(info))
    }
  }, [])

  const handleLogout = () => {
    localStorage.removeItem('admin_token')
    localStorage.removeItem('admin_info')
    setIsAuthenticated(false)
    setAdminInfo(null)
    navigate('/login')
  }

  const menuItems = [
    {
      key: '/dashboard',
      icon: <DashboardOutlined />,
      label: '数据概览',
      onClick: () => navigate('/dashboard'),
    },
    {
      key: '/methods',
      icon: <FileTextOutlined />,
      label: '方法管理',
      onClick: () => navigate('/methods'),
    },
    {
      key: '/approval',
      icon: <CheckCircleOutlined />,
      label: '内容审核',
      onClick: () => navigate('/approval'),
    },
    {
      key: '/media',
      icon: <CloudUploadOutlined />,
      label: '媒体库',
      onClick: () => navigate('/media'),
    },
    {
      key: '/export',
      icon: <ExportOutlined />,
      label: '数据导出',
      onClick: () => navigate('/export'),
    },
    {
      key: '/users',
      icon: <TeamOutlined />,
      label: '用户管理',
      onClick: () => navigate('/users'),
    },
  ]

  const userMenuItems = [
    {
      key: 'logout',
      icon: <LogoutOutlined />,
      label: '退出登录',
      onClick: handleLogout,
    },
  ]

  if (!isAuthenticated) {
    return (
      <Routes>
        <Route path="/login" element={<Login onLoginSuccess={() => setIsAuthenticated(true)} />} />
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    )
  }

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Sider width={200} theme="dark">
        <div style={{ 
          height: 64, 
          display: 'flex', 
          alignItems: 'center', 
          justifyContent: 'center',
          color: 'white',
          fontSize: 18,
          fontWeight: 'bold'
        }}>
          心理自助管理后台
        </div>
        <Menu
          theme="dark"
          mode="inline"
          defaultSelectedKeys={['/dashboard']}
          items={menuItems}
        />
      </Sider>
      <Layout>
        <Header style={{ background: '#fff', padding: '0 24px', display: 'flex', justifyContent: 'flex-end', alignItems: 'center' }}>
          <Dropdown menu={{ items: userMenuItems }} placement="bottomRight">
            <div style={{ cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8 }}>
              <Avatar icon={<UserOutlined />} />
              <span>{adminInfo?.username || '管理员'}</span>
            </div>
          </Dropdown>
        </Header>
        <Content style={{ margin: '24px', background: '#fff', padding: 24, minHeight: 280 }}>
          <Routes>
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/methods" element={<MethodList />} />
            <Route path="/methods/new" element={<MethodEdit />} />
            <Route path="/methods/edit/:id" element={<MethodEdit />} />
            <Route path="/approval" element={<MethodApproval />} />
            <Route path="/media" element={<MediaLibrary />} />
            <Route path="/export" element={<DataExport />} />
            <Route path="/users" element={<UserManagement />} />
            <Route path="/" element={<Navigate to="/dashboard" replace />} />
          </Routes>
        </Content>
      </Layout>
    </Layout>
  )
}

export default App
