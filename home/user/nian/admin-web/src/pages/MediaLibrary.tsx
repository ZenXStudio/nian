import React, { useState, useEffect } from 'react';
import {
  Table,
  Button,
  Upload,
  message,
  Modal,
  Input,
  Select,
  Space,
  Image,
  Popconfirm,
  Typography,
  Card,
  Row,
  Col,
  Statistic,
} from 'antd';
import {
  UploadOutlined,
  DeleteOutlined,
  EyeOutlined,
  CopyOutlined,
  CloudUploadOutlined,
  FileImageOutlined,
  AudioOutlined,
  VideoCameraOutlined,
} from '@ant-design/icons';
import type { UploadProps } from 'antd';
import { api } from '../services/api';

const { Search } = Input;
const { Option } = Select;
const { Title, Text } = Typography;

interface MediaFile {
  id: number;
  filename: string;
  original_name: string;
  file_type: 'image' | 'audio' | 'video';
  mime_type: string;
  file_size: number;
  url: string;
  uploaded_by_name?: string;
  created_at: string;
}

const MediaLibrary: React.FC = () => {
  const [files, setFiles] = useState<MediaFile[]>([]);
  const [loading, setLoading] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 20,
    total: 0,
  });
  const [filters, setFilters] = useState({
    type: 'all',
    search: '',
  });
  const [previewVisible, setPreviewVisible] = useState(false);
  const [previewFile, setPreviewFile] = useState<MediaFile | null>(null);
  const [statistics, setStatistics] = useState({
    totalFiles: 0,
    totalImages: 0,
    totalAudios: 0,
    totalVideos: 0,
  });

  useEffect(() => {
    fetchFiles();
    fetchStatistics();
  }, [pagination.current, pagination.pageSize, filters]);

  const fetchFiles = async () => {
    setLoading(true);
    try {
      const response = await api.get('/admin/media', {
        params: {
          type: filters.type,
          search: filters.search,
          page: pagination.current,
          pageSize: pagination.pageSize,
        },
      });

      if (response.data.success) {
        setFiles(response.data.data.items);
        setPagination({
          ...pagination,
          total: response.data.data.total,
        });
      }
    } catch (error) {
      message.error('获取媒体文件列表失败');
    } finally {
      setLoading(false);
    }
  };

  const fetchStatistics = async () => {
    try {
      const allFiles = await api.get('/admin/media', {
        params: { type: 'all', page: 1, pageSize: 1 },
      });
      const images = await api.get('/admin/media', {
        params: { type: 'image', page: 1, pageSize: 1 },
      });
      const audios = await api.get('/admin/media', {
        params: { type: 'audio', page: 1, pageSize: 1 },
      });
      const videos = await api.get('/admin/media', {
        params: { type: 'video', page: 1, pageSize: 1 },
      });

      setStatistics({
        totalFiles: allFiles.data.data.total,
        totalImages: images.data.data.total,
        totalAudios: audios.data.data.total,
        totalVideos: videos.data.data.total,
      });
    } catch (error) {
      console.error('获取统计信息失败', error);
    }
  };

  const uploadProps: UploadProps = {
    name: 'file',
    action: `${import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000'}/api/admin/upload`,
    headers: {
      Authorization: `Bearer ${localStorage.getItem('token')}`,
    },
    beforeUpload: (file) => {
      const isImage = file.type.startsWith('image/');
      const isAudio = file.type.startsWith('audio/');
      const isVideo = file.type.startsWith('video/');

      if (!isImage && !isAudio && !isVideo) {
        message.error('只能上传图片、音频或视频文件！');
        return false;
      }

      const maxSize = isImage ? 5 : isAudio ? 20 : 100;
      const isLtMaxSize = file.size / 1024 / 1024 < maxSize;

      if (!isLtMaxSize) {
        message.error(`文件大小不能超过 ${maxSize}MB！`);
        return false;
      }

      return true;
    },
    onChange(info) {
      if (info.file.status === 'uploading') {
        setUploading(true);
      }
      if (info.file.status === 'done') {
        setUploading(false);
        message.success(`${info.file.name} 上传成功`);
        fetchFiles();
        fetchStatistics();
      } else if (info.file.status === 'error') {
        setUploading(false);
        message.error(`${info.file.name} 上传失败`);
      }
    },
  };

  const handleDelete = async (id: number) => {
    try {
      await api.delete(`/admin/media/${id}`);
      message.success('删除成功');
      fetchFiles();
      fetchStatistics();
    } catch (error) {
      message.error('删除失败');
    }
  };

  const handlePreview = (file: MediaFile) => {
    setPreviewFile(file);
    setPreviewVisible(true);
  };

  const handleCopyUrl = (url: string) => {
    const fullUrl = `${import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000'}${url}`;
    navigator.clipboard.writeText(fullUrl);
    message.success('URL已复制到剪贴板');
  };

  const formatFileSize = (bytes: number) => {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
  };

  const getFileTypeIcon = (type: string) => {
    switch (type) {
      case 'image':
        return <FileImageOutlined style={{ fontSize: 24, color: '#52c41a' }} />;
      case 'audio':
        return <AudioOutlined style={{ fontSize: 24, color: '#1890ff' }} />;
      case 'video':
        return <VideoCameraOutlined style={{ fontSize: 24, color: '#fa8c16' }} />;
      default:
        return null;
    }
  };

  const renderPreview = () => {
    if (!previewFile) return null;

    const fullUrl = `${import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000'}${previewFile.url}`;

    if (previewFile.file_type === 'image') {
      return <Image src={fullUrl} alt={previewFile.original_name} style={{ maxWidth: '100%' }} />;
    } else if (previewFile.file_type === 'audio') {
      return (
        <audio controls style={{ width: '100%' }}>
          <source src={fullUrl} type={previewFile.mime_type} />
          您的浏览器不支持音频播放。
        </audio>
      );
    } else if (previewFile.file_type === 'video') {
      return (
        <video controls style={{ width: '100%', maxHeight: '500px' }}>
          <source src={fullUrl} type={previewFile.mime_type} />
          您的浏览器不支持视频播放。
        </video>
      );
    }
    return null;
  };

  const columns = [
    {
      title: '类型',
      dataIndex: 'file_type',
      key: 'file_type',
      width: 80,
      render: (type: string) => getFileTypeIcon(type),
    },
    {
      title: '文件名',
      dataIndex: 'original_name',
      key: 'original_name',
      ellipsis: true,
    },
    {
      title: '大小',
      dataIndex: 'file_size',
      key: 'file_size',
      width: 100,
      render: (size: number) => formatFileSize(size),
    },
    {
      title: '上传者',
      dataIndex: 'uploaded_by_name',
      key: 'uploaded_by_name',
      width: 120,
    },
    {
      title: '上传时间',
      dataIndex: 'created_at',
      key: 'created_at',
      width: 180,
      render: (date: string) => new Date(date).toLocaleString('zh-CN'),
    },
    {
      title: '操作',
      key: 'action',
      width: 200,
      render: (_: any, record: MediaFile) => (
        <Space>
          <Button
            type="link"
            icon={<EyeOutlined />}
            onClick={() => handlePreview(record)}
          >
            预览
          </Button>
          <Button
            type="link"
            icon={<CopyOutlined />}
            onClick={() => handleCopyUrl(record.url)}
          >
            复制URL
          </Button>
          <Popconfirm
            title="确定要删除这个文件吗？"
            onConfirm={() => handleDelete(record.id)}
            okText="确定"
            cancelText="取消"
          >
            <Button type="link" danger icon={<DeleteOutlined />}>
              删除
            </Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div style={{ padding: 24 }}>
      <Title level={2}>媒体库管理</Title>

      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col span={6}>
          <Card>
            <Statistic
              title="总文件数"
              value={statistics.totalFiles}
              prefix={<CloudUploadOutlined />}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="图片"
              value={statistics.totalImages}
              prefix={<FileImageOutlined />}
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="音频"
              value={statistics.totalAudios}
              prefix={<AudioOutlined />}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="视频"
              value={statistics.totalVideos}
              prefix={<VideoCameraOutlined />}
              valueStyle={{ color: '#fa8c16' }}
            />
          </Card>
        </Col>
      </Row>

      <Card style={{ marginBottom: 16 }}>
        <Space style={{ marginBottom: 16, width: '100%', justifyContent: 'space-between' }}>
          <Space>
            <Select
              value={filters.type}
              onChange={(value) => setFilters({ ...filters, type: value })}
              style={{ width: 120 }}
            >
              <Option value="all">全部类型</Option>
              <Option value="image">图片</Option>
              <Option value="audio">音频</Option>
              <Option value="video">视频</Option>
            </Select>
            <Search
              placeholder="搜索文件名"
              allowClear
              onSearch={(value) => setFilters({ ...filters, search: value })}
              style={{ width: 300 }}
            />
          </Space>
          <Upload {...uploadProps} showUploadList={false}>
            <Button type="primary" icon={<UploadOutlined />} loading={uploading}>
              上传文件
            </Button>
          </Upload>
        </Space>

        <Table
          columns={columns}
          dataSource={files}
          rowKey="id"
          loading={loading}
          pagination={{
            ...pagination,
            showSizeChanger: true,
            showQuickJumper: true,
            showTotal: (total) => `共 ${total} 个文件`,
            onChange: (page, pageSize) => {
              setPagination({ ...pagination, current: page, pageSize: pageSize || 20 });
            },
          }}
        />
      </Card>

      <Modal
        title={previewFile?.original_name}
        open={previewVisible}
        onCancel={() => setPreviewVisible(false)}
        footer={[
          <Button key="copy" icon={<CopyOutlined />} onClick={() => previewFile && handleCopyUrl(previewFile.url)}>
            复制URL
          </Button>,
          <Button key="close" onClick={() => setPreviewVisible(false)}>
            关闭
          </Button>,
        ]}
        width={800}
      >
        {renderPreview()}
        {previewFile && (
          <div style={{ marginTop: 16 }}>
            <Text type="secondary">
              文件大小: {formatFileSize(previewFile.file_size)} | 
              MIME类型: {previewFile.mime_type} | 
              上传时间: {new Date(previewFile.created_at).toLocaleString('zh-CN')}
            </Text>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default MediaLibrary;
