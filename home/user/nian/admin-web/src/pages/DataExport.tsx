import React, { useState } from 'react';
import {
  Card,
  Form,
  Select,
  DatePicker,
  Button,
  message,
  Typography,
  Space,
  Row,
  Col,
  Divider,
  Alert,
} from 'antd';
import { DownloadOutlined, FileTextOutlined, FileExcelOutlined } from '@ant-design/icons';
import { api } from '../services/api';
import dayjs from 'dayjs';

const { Title, Text } = Typography;
const { Option } = Select;
const { RangePicker } = DatePicker;

const DataExport: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [form] = Form.useForm();

  const handleExport = async (values: any) => {
    setLoading(true);
    try {
      let endpoint = '';
      const params: any = {
        format: values.format,
      };

      switch (values.dataType) {
        case 'users':
          endpoint = '/admin/export/users';
          if (values.dateRange) {
            params.startDate = values.dateRange[0].format('YYYY-MM-DD');
            params.endDate = values.dateRange[1].format('YYYY-MM-DD');
          }
          if (values.userStatus) {
            params.status = values.userStatus;
          }
          break;

        case 'methods':
          endpoint = '/admin/export/methods';
          if (values.category) {
            params.category = values.category;
          }
          if (values.methodStatus) {
            params.status = values.methodStatus;
          }
          break;

        case 'practices':
          endpoint = '/admin/export/practices';
          if (!values.dateRange || values.dateRange.length !== 2) {
            message.error('练习记录导出必须选择日期范围');
            setLoading(false);
            return;
          }
          params.startDate = values.dateRange[0].format('YYYY-MM-DD');
          params.endDate = values.dateRange[1].format('YYYY-MM-DD');
          if (values.userId) {
            params.userId = values.userId;
          }
          break;
      }

      const response = await api.get(endpoint, {
        params,
        responseType: values.format === 'json' ? 'json' : 'blob',
      });

      if (values.format === 'json') {
        // JSON格式直接下载
        const jsonStr = JSON.stringify(response.data.data, null, 2);
        const blob = new Blob([jsonStr], { type: 'application/json' });
        const url = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `${values.dataType}_${dayjs().format('YYYY-MM-DD_HH-mm-ss')}.json`;
        link.click();
        window.URL.revokeObjectURL(url);
      } else {
        // CSV/Excel格式
        const url = window.URL.createObjectURL(response.data);
        const link = document.createElement('a');
        link.href = url;
        const extension = values.format === 'excel' ? 'xlsx' : 'csv';
        link.download = `${values.dataType}_${dayjs().format('YYYY-MM-DD_HH-mm-ss')}.${extension}`;
        link.click();
        window.URL.revokeObjectURL(url);
      }

      message.success('导出成功');
    } catch (error) {
      message.error('导出失败');
    } finally {
      setLoading(false);
    }
  };

  const getFormatOptions = (dataType: string) => {
    if (dataType === 'practices') {
      return [
        { label: 'CSV', value: 'csv' },
        { label: 'Excel', value: 'excel' },
        { label: 'JSON', value: 'json' },
      ];
    }
    return [
      { label: 'CSV', value: 'csv' },
      { label: 'JSON', value: 'json' },
    ];
  };

  return (
    <div style={{ padding: 24 }}>
      <Title level={2}>数据导出</Title>

      <Alert
        message="导出说明"
        description="请选择要导出的数据类型和格式。导出的文件将自动下载到您的计算机。注意：大量数据导出可能需要一些时间，请耐心等待。"
        type="info"
        showIcon
        style={{ marginBottom: 24 }}
      />

      <Row gutter={24}>
        <Col span={12}>
          <Card title="用户数据导出" extra={<FileTextOutlined />}>
            <Form
              form={form}
              layout="vertical"
              onFinish={(values) => handleExport({ ...values, dataType: 'users' })}
            >
              <Form.Item
                label="导出格式"
                name="format"
                initialValue="csv"
                rules={[{ required: true, message: '请选择导出格式' }]}
              >
                <Select>
                  <Option value="csv">CSV</Option>
                  <Option value="json">JSON</Option>
                </Select>
              </Form.Item>

              <Form.Item label="日期范围" name="dateRange">
                <RangePicker style={{ width: '100%' }} />
              </Form.Item>

              <Form.Item label="用户状态" name="userStatus">
                <Select allowClear placeholder="全部状态">
                  <Option value="all">全部</Option>
                  <Option value="active">激活</Option>
                  <Option value="inactive">禁用</Option>
                </Select>
              </Form.Item>

              <Form.Item>
                <Button type="primary" htmlType="submit" icon={<DownloadOutlined />} loading={loading} block>
                  导出用户数据
                </Button>
              </Form.Item>
            </Form>
          </Card>
        </Col>

        <Col span={12}>
          <Card title="方法数据导出" extra={<FileTextOutlined />}>
            <Form
              layout="vertical"
              onFinish={(values) => handleExport({ ...values, dataType: 'methods' })}
            >
              <Form.Item
                label="导出格式"
                name="format"
                initialValue="csv"
                rules={[{ required: true, message: '请选择导出格式' }]}
              >
                <Select>
                  <Option value="csv">CSV</Option>
                  <Option value="json">JSON</Option>
                </Select>
              </Form.Item>

              <Form.Item label="分类筛选" name="category">
                <Select allowClear placeholder="全部分类">
                  <Option value="放松技巧">放松技巧</Option>
                  <Option value="认知调整">认知调整</Option>
                  <Option value="情绪管理">情绪管理</Option>
                  <Option value="行为改变">行为改变</Option>
                </Select>
              </Form.Item>

              <Form.Item label="方法状态" name="methodStatus">
                <Select allowClear placeholder="全部状态">
                  <Option value="all">全部</Option>
                  <Option value="draft">草稿</Option>
                  <Option value="pending">待审核</Option>
                  <Option value="published">已发布</Option>
                </Select>
              </Form.Item>

              <Form.Item>
                <Button type="primary" htmlType="submit" icon={<DownloadOutlined />} loading={loading} block>
                  导出方法数据
                </Button>
              </Form.Item>
            </Form>
          </Card>
        </Col>
      </Row>

      <Divider />

      <Row gutter={24}>
        <Col span={12}>
          <Card title="练习记录导出" extra={<FileExcelOutlined />}>
            <Form
              layout="vertical"
              onFinish={(values) => handleExport({ ...values, dataType: 'practices' })}
            >
              <Form.Item
                label="导出格式"
                name="format"
                initialValue="excel"
                rules={[{ required: true, message: '请选择导出格式' }]}
              >
                <Select>
                  <Option value="csv">CSV</Option>
                  <Option value="excel">Excel</Option>
                  <Option value="json">JSON</Option>
                </Select>
              </Form.Item>

              <Form.Item
                label="日期范围"
                name="dateRange"
                rules={[{ required: true, message: '请选择日期范围' }]}
              >
                <RangePicker style={{ width: '100%' }} />
              </Form.Item>

              <Form.Item label="用户ID筛选" name="userId">
                <Select allowClear placeholder="全部用户" showSearch>
                  {/* 这里可以动态加载用户列表 */}
                </Select>
              </Form.Item>

              <Form.Item>
                <Button type="primary" htmlType="submit" icon={<DownloadOutlined />} loading={loading} block>
                  导出练习记录
                </Button>
              </Form.Item>
            </Form>

            <Alert
              message="提示"
              description="练习记录导出必须指定日期范围，建议选择不超过3个月的时间段以确保导出速度。"
              type="warning"
              showIcon
              style={{ marginTop: 16 }}
            />
          </Card>
        </Col>

        <Col span={12}>
          <Card title="导出历史记录">
            <Space direction="vertical" style={{ width: '100%' }}>
              <Text type="secondary">最近导出的文件会在24小时后自动清理</Text>
              <Text type="secondary">如需长期保存，请及时下载到本地</Text>
              <Divider />
              <Text strong>导出文件说明：</Text>
              <ul style={{ paddingLeft: 20 }}>
                <li>CSV格式适合用Excel打开查看</li>
                <li>JSON格式适合程序处理和数据分析</li>
                <li>Excel格式支持更丰富的数据展示</li>
              </ul>
            </Space>
          </Card>
        </Col>
      </Row>
    </div>
  );
};

export default DataExport;
