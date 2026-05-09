<script def>
{
  "navigationBarTitleText": "麻将识牌",
  "description": "当用户说看看我的牌、识别手牌、帮我看看牌、这是什么牌、拍照识牌时触发。调用前必须先使用眼镜摄像头拍摄用户面前的麻将牌面照片，然后通过视觉大模型识别照片中的麻将牌，将识别结果填入 hand_tiles、peng_tiles、gang_tiles、confidence 四个参数传入页面。识别规则：1）hand_tiles为手牌列表，每张牌用中文空格分隔，如"一万 一万 三万 五条 七条"；2）peng_tiles为碰出的牌，空格分隔，如"东风 三万"，没有碰牌返回"无"；3）gang_tiles为杠出的牌，空格分隔，如"五筒"，没有杠牌返回"无"；4）同一张牌出现多次时需重复列出；5）四川麻将不含字牌（东南西北中发白），国标麻将包含所有牌型；6）如果照片模糊无法识别，在confidence中填入low。",
  "schema": {
    "data": {
      "type": "object",
      "properties": {
        "hand_tiles": {
          "type": "string",
          "minLength": 1,
          "description": "手牌列表，每张牌用空格分隔。万子：一万~九万；条子：一条~九条；筒子：一筒~九筒；字牌：东风、南风、西风、北风、红中、发财、白板。同一张牌出现多次需重复列出。如：一万 一万 三万 五条 七条 七条 九条 二筒 四筒 六筒 八筒 八筒 九筒",
          "default": "一万 二万 三万 四万 五万 六万 七万 八条 九条 一筒 二筒 三筒"
        },
        "peng_tiles": {
          "type": "string",
          "description": "碰出的牌，空格分隔，每组碰牌只需写一次牌名。如：东风 三万。没有碰牌返回无",
          "default": "无"
        },
        "gang_tiles": {
          "type": "string",
          "description": "杠出的牌，空格分隔，每组杠牌只需写一次牌名。如：五筒。没有杠牌返回无",
          "default": "无"
        },
        "confidence": {
          "type": "string",
          "enum": ["high", "medium", "low"],
          "description": "识别置信度。high=清晰可辨，medium=部分模糊但可推断，low=模糊难以确认",
          "default": "medium"
        }
      },
      "required": ["hand_tiles", "peng_tiles", "gang_tiles", "confidence"]
    }
  }
}
</script>

<script setup>
export default {
  data: {
    handTiles: '',
    pengTiles: '',
    gangTiles: '',
    confidence: '',
    hasResult: false,
    handCount: 0
  },

  onLoad(options) {
    if (options && options.hand_tiles) {
      var hand = options.hand_tiles;
      var count = hand.split(' ').filter(function(t) { return t.length > 0; }).length;
      this.setData({
        handTiles: hand,
        pengTiles: options.peng_tiles || '无',
        gangTiles: options.gang_tiles || '无',
        confidence: options.confidence || 'medium',
        hasResult: true,
        handCount: count
      });
    }
  }
};
</script>

<page>
  <view class="container">
    <view ink:if="{{ hasResult }}" class="result-card">
      <view class="section">
        <text class="section-title">手牌 ({{ handCount }}张)</text>
        <text class="tiles-text">{{ handTiles }}</text>
      </view>

      <view ink:if="{{ pengTiles !== '无' }}" class="section">
        <text class="section-title label-peng">碰</text>
        <text class="tiles-text text-peng">{{ pengTiles }}</text>
      </view>

      <view ink:if="{{ gangTiles !== '无' }}" class="section">
        <text class="section-title label-gang">杠</text>
        <text class="tiles-text text-gang">{{ gangTiles }}</text>
      </view>

      <view ink:if="{{ confidence === 'low' }}" class="warn-row">
        <text class="warn-text">置信度较低，建议重新拍照</text>
      </view>
    </view>

    <view ink:else class="empty-card">
      <text class="empty-text">说"看看我的牌"开始识别</text>
    </view>
  </view>
</page>

<style>
.container {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 480px;
  height: 380px;
  background-color: #000;
  box-sizing: border-box;
  padding: 10px;
}

.result-card {
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 100%;
  height: 100%;
  border: 2px solid #40FF5E;
  border-radius: 12px;
  padding: 16px 20px;
  box-sizing: border-box;
  background-color: rgba(64, 255, 94, 0.04);
}

.section {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.section-title {
  font-size: 14px;
  color: rgba(64, 255, 94, 0.6);
  font-weight: bold;
}

.label-peng {
  color: rgba(255, 170, 43, 0.8);
}

.label-gang {
  color: rgba(100, 149, 237, 0.8);
}

.tiles-text {
  font-size: 18px;
  color: #40FF5E;
  font-weight: bold;
  line-height: 24px;
}

.text-peng {
  color: #ffaa2b;
}

.text-gang {
  color: #6495ed;
}

.warn-row {
  display: flex;
  justify-content: flex-end;
}

.warn-text {
  font-size: 14px;
  color: #ff6b6b;
}

.empty-card {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 100%;
  border: 2px dashed rgba(64, 255, 94, 0.3);
  border-radius: 12px;
}

.empty-text {
  font-size: 18px;
  color: rgba(64, 255, 94, 0.4);
}
</style>
