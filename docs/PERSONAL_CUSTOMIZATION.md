# 个人改造说明

本项目用于个人学习、研究和非商业创作。应用名称、副标题可以在
`config/config.yaml` 的 `app` 区块中修改：

```yaml
app:
  name: 我的 AI 视频工作室
  subtitle: 本地优先的个人视频创作工具
  attribution: 基于 JJYB_AI_VideoAutoCut 改造
```

`attribution` 用于保留上游来源说明，不应删除。后续新增个人功能时，建议优先放在独立的服务层或扩展模块中，避免直接改写分镜、同步、渲染等核心引擎。
