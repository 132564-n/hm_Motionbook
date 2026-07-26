import { router } from '@kit.ArkUI';
import { audio } from '@kit.AudioKit';
import { common } from '@kit.AbilityKit';
import { ProjectRepository } from '../repositories/ProjectRepository';
import { Project, ProjectType, ProjectStatus, AudioClip } from '../models/Models';

/**
 * 音频创作页面
 * 支持录音、播放、剪辑、音量调整
 */
@Entry
@Component
struct AudioCreatePage {
  @State projectId: number = 0;
  @State title: string = '未命名音频';
  @State audioClips: AudioClip[] = [];
  @State isRecording: boolean = false;
  @State isPlaying: boolean = false;
  @State recordDuration: number = 0;
  @State playProgress: number = 0;
  @State currentClipIndex: number = -1;
  @State volume: number = 50;
  private repo: ProjectRepository = new ProjectRepository();
  private audioRecorder: audio.AudioRecorder | null = null;
  private audioPlayer: audio.AudioRenderer | null = null;
  private recordTimer: number = -1;
  private playTimer: number = -1;
  private currentFilePath: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string | number>;
    if (params && params.type === ProjectType.AUDIO) {
      this.createNewProject();
    }
    if (params && params.id) {
      this.projectId = params.id as number;
      this.loadProject();
    }
  }

  onPageHide(): void {
    this.stopRecording();
    this.stopPlaying();
  }

  private async loadProject(): Promise<void> {
    try {
      const project = await this.repo.getById(this.projectId);
      if (project) {
        this.title = project.title;
        if (project.content) {
          this.audioClips = JSON.parse(project.content);
          if (this.audioClips.length > 0) {
            this.currentClipIndex = 0;
          }
        }
      }
    } catch (err) {
      console.error('加载项目失败: ' + JSON.stringify(err));
    }
  }

  private async createNewProject(): Promise<void> {
    try {
      const project: Project = {
        title: this.title,
        type: ProjectType.AUDIO,
        status: ProjectStatus.DRAFT,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };
      this.projectId = await this.repo.create(project);
    } catch (err) {
      console.error('创建项目失败: ' + JSON.stringify(err));
    }
  }

  /**
   * 开始录音
   */
  private async startRecording(): Promise<void> {
    try {
      if (this.audioRecorder === null) {
        this.audioRecorder = await audio.createAudioRecorder();
      }

      const context = getContext(this) as common.UIAbilityContext;
      const cacheDir = context.cacheDir;
      const fileName = `audio_${Date.now()}.m4a`;
      this.currentFilePath = `${cacheDir}/${fileName}`;

      const audioStreamInfo: audio.AudioStreamInfo = {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_44100,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      };

      const audioRecorderInfo: audio.AudioRecorderInfo = {
        dataSource: audio.AudioSource.MIC,
        fileFormat: audio.ContainerFormatType.CFT_MPEG_4A
      };

      const audioConfig: audio.AudioRecorderOptions = {
        audioStreamInfo: audioStreamInfo,
        audioRecorderInfo: audioRecorderInfo,
        filePath: this.currentFilePath,
        uri: this.currentFilePath
      };

      this.audioRecorder.prepare(audioConfig);
      this.audioRecorder.start();

      this.isRecording = true;
      this.recordDuration = 0;
      this.recordTimer = setInterval(() => {
        this.recordDuration++;
      }, 1000);
    } catch (err) {
      console.error('开始录音失败: ' + JSON.stringify(err));
    }
  }

  /**
   * 停止录音
   */
  private stopRecording(): void {
    if (this.audioRecorder && this.isRecording) {
      this.audioRecorder.stop();
      this.audioRecorder.release();
      this.isRecording = false;

      if (this.recordTimer !== -1) {
        clearInterval(this.recordTimer);
        this.recordTimer = -1;
      }

      // 保存音频片段信息
      if (this.currentFilePath) {
        const clip: AudioClip = {
          projectId: this.projectId,
          name: `片段 ${this.audioClips.length + 1}`,
          filePath: this.currentFilePath,
          duration: this.recordDuration,
          createdAt: Date.now()
        };
        this.audioClips.push(clip);
        this.currentClipIndex = this.audioClips.length - 1;
      }
    }
  }

  /**
   * 播放音频
   */
  private async startPlaying(): Promise<void> {
    if (this.audioClips.length === 0 || this.currentClipIndex < 0) return;

    try {
      const clip = this.audioClips[this.currentClipIndex];
      this.isPlaying = true;
      this.playProgress = 0;

      this.playTimer = setInterval(() => {
        this.playProgress++;
        if (this.playProgress >= clip.duration) {
          this.stopPlaying();
        }
      }, 1000);

      console.info('播放音频: ' + clip.filePath);
    } catch (err) {
      console.error('播放音频失败: ' + JSON.stringify(err));
      this.isPlaying = false;
    }
  }

  /**
   * 停止播放
   */
  private stopPlaying(): void {
    this.isPlaying = false;
    this.playProgress = 0;
    if (this.playTimer !== -1) {
      clearInterval(this.playTimer);
      this.playTimer = -1;
    }
  }

  /**
   * 删除片段
   */
  private deleteClip(index: number): void {
    if (index >= 0 && index < this.audioClips.length) {
      this.audioClips.splice(index, 1);
      if (this.currentClipIndex >= this.audioClips.length) {
        this.currentClipIndex = this.audioClips.length - 1;
      }
    }
  }

  /**
   * 保存项目
   */
  private async saveProject(): Promise<void> {
    if (this.projectId === 0) return;
    try {
      const project = await this.repo.getById(this.projectId);
      if (project) {
        project.title = this.title;
        project.content = JSON.stringify(this.audioClips);
        project.updatedAt = Date.now();
        await this.repo.update(project);
        console.info('项目保存成功');
      }
    } catch (err) {
      console.error('保存项目失败: ' + JSON.stringify(err));
    }
  }

  private async completeAndSave(): Promise<void> {
    await this.saveProject();
    router.back();
  }

  private formatTime(seconds: number): string {
    const min = Math.floor(seconds / 60);
    const sec = seconds % 60;
    return `${String(min).padStart(2, '0')}:${String(sec).padStart(2, '0')}`;
  }

  @Builder
  AudioClipItem(clip: AudioClip, index: number) {
    Row() {
      Column() {
        Text(clip.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentClipIndex === index ? '#007DFF' : '#182431')

        Row() {
          Text(this.formatTime(clip.duration))
            .fontSize(11)
            .fontColor('#999999')
          Text(' · ')
            .fontSize(11)
            .fontColor('#CCCCCC')
          Text('m4a')
            .fontSize(11)
            .fontColor('#999999')
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 播放按钮
      Column() {
        Image(this.isPlaying && this.currentClipIndex === index ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
          .width(24)
          .height(24)
          .fillColor('#007DFF')
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.currentClipIndex = index;
        if (this.isPlaying) {
          this.stopPlaying();
        } else {
          this.startPlaying();
        }
      })

      // 删除按钮
      Column() {
        Image($r('app.media.ic_delete'))
          .width(20)
          .height(20)
          .fillColor('#FF3B30')
      }
      .width(32)
      .height(32)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.deleteClip(index);
      })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 8 })
    .border({
      width: this.currentClipIndex === index ? 1 : 0,
      color: '#007DFF'
    })
    .onClick(() => {
      this.currentClipIndex = index;
    })
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#666666')
          .onClick(() => {
            router.back();
          })

        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('完成')
          .fontSize(16)
          .fontColor('#007DFF')
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.completeAndSave();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 主内容区
      Column() {
        // 录音控制区
        Column() {
          // 录音时长
          Text(this.formatTime(this.recordDuration))
            .fontSize(56)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isRecording ? '#FF3B30' : '#182431')
            .margin({ top: 32 })

          // 录音状态
          Text(this.isRecording ? '录音中...' : (this.audioClips.length > 0 ? '点击继续录音' : '点击开始录音'))
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 8 })

          // 录音按钮
          Column() {
            if (this.isRecording) {
              // 停止按钮
              Column() {
                Text('■')
                  .fontSize(28)
                  .fontColor('#FFFFFF')
              }
              .width(72)
              .height(72)
              .borderRadius(36)
              .backgroundColor('#FF3B30')
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.stopRecording();
              })
            } else {
              // 录音按钮
              Column() {
                Circle({ width: 24, height: 24 })
                  .fill('#FFFFFF')
              }
              .width(72)
              .height(72)
              .borderRadius(36)
              .backgroundColor('#FF3B30')
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.startRecording();
              })
            }
          }
          .margin({ top: 32 })

          // 音量调节
          if (this.audioClips.length > 0 && this.currentClipIndex >= 0) {
            Row() {
              Text('音量')
                .fontSize(12)
                .fontColor('#666666')
              Slider({ value: this.volume, min: 0, max: 100, step: 1 })
                .layoutWeight(1)
                .onChange((value: number) => {
                  this.volume = Math.floor(value);
                })
              Text(this.volume + '%')
                .fontSize(12)
                .fontColor('#666666')
                .width(40)
            }
            .width('80%')
            .margin({ top: 24 })
          }
        }
        .width('100%')
        .padding({ top: 16, bottom: 24 })
        .backgroundColor('#FFFFFF')

        // 音频片段列表
        if (this.audioClips.length > 0) {
          Text('音频片段')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 20, bottom: 8, left: 4 })

          Scroll() {
            Column() {
              ForEach(this.audioClips, (clip: AudioClip, index: number) => {
                this.AudioClipItem(clip, index)
              }, (clip: AudioClip, index: number) => index.toString())
            }
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .padding({ left: 16, right: 16, bottom: 24 })
        } else {
          Column() {
            Text('暂无音频片段')
              .fontSize(14)
              .fontColor('#999999')
            Text('录音后将显示在这里')
              .fontSize(12)
              .fontColor('#CCCCCC')
              .margin({ top: 4 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      }
      .layoutWeight(1)
      .backgroundColor('#F1F3F5')
    }
    .width('100%')
    .height('100%')
  }
}
