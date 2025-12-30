import apiClient from '../utils/request'

export interface LoginParams {
  username: string
  password: string
}

export interface MethodParams {
  title: string
  category: string
  difficulty: string
  duration: number
  description: string
  content_json: any
  status?: string
}

// 管理员登录
export const adminLogin = (data: LoginParams) => {
  return apiClient.post('/admin/login', data)
}

// 获取统计数据
export const getAdminStats = () => {
  return apiClient.get('/admin/stats')
}

// 方法管理
export const getMethods = (params?: any) => {
  return apiClient.get('/admin/methods', { params })
}

export const getMethodById = (id: number) => {
  return apiClient.get(`/admin/methods/${id}`)
}

export const createMethod = (data: MethodParams) => {
  return apiClient.post('/admin/methods', data)
}

export const updateMethod = (id: number, data: MethodParams) => {
  return apiClient.put(`/admin/methods/${id}`, data)
}

export const deleteMethod = (id: number) => {
  return apiClient.delete(`/admin/methods/${id}`)
}

// 内容审核
export const getPendingMethods = (params?: any) => {
  return apiClient.get('/admin/methods/pending', { params })
}

export const approveMethod = (id: number, comment?: string) => {
  return apiClient.post(`/admin/methods/${id}/approve`, { comment })
}

export const rejectMethod = (id: number, comment: string) => {
  return apiClient.post(`/admin/methods/${id}/reject`, { comment })
}
import apiClient from '../utils/request'

export interface LoginParams {
  username: string
  password: string
}

export interface MethodParams {
  title: string
  category: string
  difficulty: string
  duration: number
  description: string
  content_json: any
  status?: string
}

// 管理员登录
export const adminLogin = (data: LoginParams) => {
  return apiClient.post('/admin/login', data)
}

// 获取统计数据
export const getAdminStats = () => {
  return apiClient.get('/admin/stats')
}

// 方法管理
export const getMethods = (params?: any) => {
  return apiClient.get('/admin/methods', { params })
}

export const getMethodById = (id: number) => {
  return apiClient.get(`/admin/methods/${id}`)
}

export const createMethod = (data: MethodParams) => {
  return apiClient.post('/admin/methods', data)
}

export const updateMethod = (id: number, data: MethodParams) => {
  return apiClient.put(`/admin/methods/${id}`, data)
}

export const deleteMethod = (id: number) => {
  return apiClient.delete(`/admin/methods/${id}`)
}

// 内容审核
export const getPendingMethods = (params?: any) => {
  return apiClient.get('/admin/methods/pending', { params })
}

export const approveMethod = (id: number, comment?: string) => {
  return apiClient.post(`/admin/methods/${id}/approve`, { comment })
}

export const rejectMethod = (id: number, comment: string) => {
  return apiClient.post(`/admin/methods/${id}/reject`, { comment })
}
