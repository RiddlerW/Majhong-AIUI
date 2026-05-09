<script def>
{
  "navigationBarTitleText": "看牌",
  "description": "当用户说看看是什么牌、看下我的牌、帮我看看牌、拍照看牌时触发。必须先使用眼镜摄像头拍摄用户面前的画面，然后根据拍摄的照片内容返回一句简短的场景描述。",
  "schema": {
    "data": {
      "type": "object",
      "properties": {
        "summary": {
          "type": "string",
          "minLength": 1,
          "description": "必须根据拍摄照片返回一句简短的场景描述，禁止返回null或空字符串。如：桌上有13张麻将牌，包含万子和条子、面前是一副麻将牌局、没有看到麻将牌，桌上有其他物品",
          "default": "拍摄完成，正在分析"
        }
      },
      "required": ["summary"]
    }
  }
}
</script>

<script setup>
export default {
  data: {
    summary: '',
    hasResult: false
  },

  onLoad(options) {
    if (options && options.summary) {
      this.setData({
        summary: options.summary,
        hasResult: true
      });
    }
  }
};
</script>

<page>
  <view class="container">
    <view ink:if="{{ hasResult }}" class="card">
      <text class="result-text">{{ summary }}</text>
    </view>
    <view ink:else class="card">
      <text class="hint-text">说"看下是什么牌"开始</text>
    </view>
  </view>
</page>

<style>
.container {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 480px;
  height: 160px;
  background-color: #000;
  box-sizing: border-box;
  padding: 12px;
}

.card {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 100%;
  border: 2px solid #40FF5E;
  border-radius: 12px;
  padding: 20px;
  box-sizing: border-box;
  background-color: rgba(64, 255, 94, 0.04);
}

.result-text {
  font-size: 20px;
  color: #40FF5E;
  font-weight: bold;
  line-height: 28px;
  text-align: center;
}

.hint-text {
  font-size: 18px;
  color: rgba(64, 255, 94, 0.4);
}
</style>
