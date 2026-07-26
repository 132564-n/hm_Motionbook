/**
 * 创作项目类型
 */
export enum ProjectType {
  IMAGE_TEXT = 'image_text',
  AUDIO = 'audio',
  TEMPLATE = 'template'
}

/**
 * 创作项目状态
 */
export enum ProjectStatus {
  DRAFT = 'draft',
  COMPLETED = 'completed',
  ARCHIVED = 'archived'
}

/**
 * 创作项目数据模型
 */
export interface Project {
  id?: number;
  title: string;
  type: ProjectType;
  status: ProjectStatus;
  coverPath?: string;
  content?: string;
  createdAt: number;
  updatedAt: number;
}

/**
 * 音频片段数据模型
 */
export interface AudioClip {
  id?: number;
  projectId: number;
  name: string;
  filePath: string;
  duration: number;
  createdAt: number;
}

/**
 * 图文页面数据模型
 */
export interface ImageTextPage {
  imageUrl: string;
  text: string;
  textStyle?: TextStyle;
}

/**
 * 文字样式
 */
export interface TextStyle {
  fontSize: number;
  color: string;
  fontWeight: number;
  textAlign: number;
  opacity: number;
}

/**
 * 模板数据模型
 */
export interface Template {
  id: string;
  name: string;
  category: string;
  thumbnail: string;
  preview: string;
}
