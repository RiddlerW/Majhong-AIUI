<script def>
{
  "navigationBarTitleText": "麻将识牌",
  "description": "当用户说看看我的牌、识别手牌、帮我看看牌、这是什么牌、拍照识牌时触发。调用前必须先使用眼镜摄像头拍摄用户面前的麻将牌面照片，然后通过视觉大模型识别照片中的麻将牌，将识别结果填入 hand_tiles、peng_tiles、gang_tiles 三个参数传入页面。识别规则：1）hand_tiles为手牌列表，每张牌用中文名称表示，如一万、二条、三筒、东风、红中、白板；2）peng_tiles为桌面上碰出的牌，每组只需写一次牌名；3）gang_tiles为桌面上杠出的牌，每组只需写一次牌名；4）同一张牌出现多次时需重复列出；5）四川麻将不含字牌（东南西北中发白），国标麻将包含所有牌型；6）如果照片模糊无法识别，在confidence中填入low。",
  "schema": {
    "data": {
      "type": "object",
      "properties": {
        "hand_tiles": {
          "type": "array",
          "items": {
            "type": "string"
          },
          "description": "手牌列表，每张牌一个中文名称。万子：一万~九万；条子：一条~九条；筒子：一筒~九筒；字牌：东风、南风、西风、北风、红中、发财、白板。同一张牌出现多次需重复列出。如：['一万','一万','三万','五条','七条','七条','九条','二筒','四筒','六筒','八筒','八筒','九筒']"
        },
        "peng_tiles": {
          "type": "array",
          "items": {
            "type": "string"
          },
          "description": "碰出的牌列表，每组碰牌只需写一次牌名。如：['东风','三万']表示碰了东风和三万两组。没有碰牌则返回空数组[]"
        },
        "gang_tiles": {
          "type": "array",
          "items": {
            "type": "string"
          },
          "description": "杠出的牌列表，每组杠牌只需写一次牌名。如：['五筒']表示杠了五筒。没有杠牌则返回空数组[]"
        },
        "confidence": {
          "type": "string",
          "enum": ["high", "medium", "low"],
          "description": "识别置信度。high=清晰可辨，medium=部分模糊但可推断，low=模糊难以确认"
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
    handTiles: [],
    pengTiles: [],
    gangTiles: [],
    confidence: '',
    hasResult: false,
    handCount: 0
  },

  onLoad(options) {
    if (options && options.hand_tiles && options.hand_tiles.length > 0) {
      var hand = options.hand_tiles;
      var peng = options.peng_tiles || [];
      var gang = options.gang_tiles || [];
      this.setData({
        handTiles: hand,
        pengTiles: peng,
        gangTiles: gang,
        confidence: options.confidence || 'medium',
        hasResult: true,
        handCount: hand.length
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
        <view class="tile-list">
          <text class="tile" ink:for="{{ handTiles }}" ink:key="*this">{{ item }}</text>
        </view>
      </view>

      <view ink:if="{{ pengTiles.length > 0 }}" class="section">
        <text class="section-title">碰</text>
        <view class="tile-list">
          <text class="tile tile-peng" ink:for="{{ pengTiles }}" ink:key="*this">{{ item }}</text>
        </view>
      </view>

      <view ink:if="{{ gangTiles.length > 0 }}" class="section">
        <text class="section-title">杠</text>
        <view class="tile-list">
          <text class="tile tile-gang" ink:for="{{ gangTiles }}" ink:key="*this">{{ item }}</text>
        </view>
      </view>

      <view ink:if="{{ confidence === 'low' }}" class="warn-row">
        <text class="warn-text">识别置信度较低，建议重新拍照</text>
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
  gap: 8px;
}

.section-title {
  font-size: 16px;
  color: rgba(64, 255, 94, 0.6);
  font-weight: bold;
}

.tile-list {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.tile {
  padding: 4px 10px;
  border: 1px solid rgba(64, 255, 94, 0.3);
  border-radius: 6px;
  background-color: rgba(64, 255, 94, 0.06);
  font-size: 16px;
  color: #40FF5E;
  font-weight: bold;
}

.tile-peng {
  border-color: rgba(255, 170, 43, 0.5);
  background-color: rgba(255, 170, 43, 0.08);
  color: #ffaa2b;
}

.tile-gang {
  border-color: rgba(100, 149, 237, 0.5);
  background-color: rgba(100, 149, 237, 0.08);
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
