<script def>
{
  "navigationBarTitleText": "分析结果",
  "description": "展示听牌和出牌建议",
  "schema": {
    "data": {
      "type": "object",
      "properties": {}
    }
  }
}
</script>
<script setup>
import wx from 'wx';

var C = require('../../lib/mahjong-constants.js');

export default {
  data: {
    handCount: 0,
    mode: 'listen',
    bestSuggestion: null,
    alternatives: [],
    listenTiles: [],
    dingque: '',
    dingqueName: ''
  },
  onLoad() {
    var app = getApp();
    var handTiles = (app && app.globalData.handTiles) || [];
    var pengTiles = (app && app.globalData.pengTiles) || [];
    var gangTiles = (app && app.globalData.gangTiles) || [];
    var ruleType = (app && app.globalData.ruleType) || wx.getStorageSync('ruleType') || 'xz';
    var dingque = (app && app.globalData.dingque) || wx.getStorageSync('dingque') || '';

    var handCount = handTiles.length;
    var dingqueName = '';
    if (dingque === 'wan') dingqueName = '万';
    else if (dingque === 'tiao') dingqueName = '条';
    else if (dingque === 'tong') dingqueName = '筒';

    this.setData({ 
      handCount: handCount,
      dingque: dingque,
      dingqueName: dingqueName
    });

    if (handCount === 13) {
      this.setData({ mode: 'listen' });
      this.calculateListening(handTiles, pengTiles, gangTiles, ruleType);
    } else if (handCount === 14) {
      this.setData({ mode: 'suggest' });
      this.calculateSuggestion(handTiles, pengTiles, gangTiles, ruleType, dingque);
    } else {
      this.setData({
        mode: 'error',
        listenTiles: [],
        bestSuggestion: null,
        alternatives: []
      });
    }
  },
  calculateListening(handTiles, pengTiles, gangTiles, ruleType) {
    var listenResult = [];
    var range = C.getRuleTileRange(ruleType);
    var count = C.tilesToCount(handTiles);

    for (var i = range.min; i <= range.max; i++) {
      if (count[i] >= 4) continue;
      count[i]++;
      if (this.isWinning(count, pengTiles, gangTiles, ruleType)) {
        listenResult.push({
          tileIndex: i,
          name: C.getTileShortName(i),
          fan: 1
        });
      }
      count[i]--;
    }

    this.setData({ listenTiles: listenResult });
  },
  calculateSuggestion(handTiles, pengTiles, gangTiles, ruleType, dingque) {
    var suggestions = [];
    var count = C.tilesToCount(handTiles);
    var range = C.getRuleTileRange(ruleType);

    var dingqueRange = null;
    if (dingque === 'wan') dingqueRange = { start: 0, end: 8 };
    else if (dingque === 'tiao') dingqueRange = { start: 9, end: 17 };
    else if (dingque === 'tong') dingqueRange = { start: 18, end: 26 };

    for (var i = 0; i < C.TILE_COUNT; i++) {
      if (count[i] <= 0) continue;

      count[i]--;
      var listenForThis = [];
      for (var j = range.min; j <= range.max; j++) {
        if (count[j] >= 4) continue;
        count[j]++;
        if (this.isWinning(count, pengTiles, gangTiles, ruleType)) {
          listenForThis.push({
            tileIndex: j,
            name: C.getTileShortName(j)
          });
        }
        count[j]--;
      }
      count[i]++;

      if (listenForThis.length > 0) {
        var isDingque = false;
        if (dingqueRange && i >= dingqueRange.start && i <= dingqueRange.end) {
          isDingque = true;
        }
        suggestions.push({
          discardIndex: i,
          discardName: C.getTileShortName(i),
          listenTiles: listenForThis,
          listenCount: listenForThis.length,
          listenNames: listenForThis.map(function(t) { return t.name; }).join(' '),
          isDingque: isDingque
        });
      }
    }

    suggestions.sort(function(a, b) {
      if (a.isDingque && !b.isDingque) return -1;
      if (!a.isDingque && b.isDingque) return 1;
      return b.listenCount - a.listenCount;
    });

    var best = suggestions.length > 0 ? suggestions[0] : null;
    var alts = suggestions.length > 1 ? suggestions.slice(1) : [];

    this.setData({
      bestSuggestion: best,
      alternatives: alts
    });
  },
  isWinning(count, pengTiles, gangTiles, ruleType) {
    var total = 0;
    for (var i = 0; i < count.length; i++) {
      total += count[i];
    }
    var meldCount = (pengTiles ? pengTiles.length : 0) + (gangTiles ? gangTiles.length : 0);
    var expectedTotal = (4 - meldCount) * 3 + 2;
    if (total !== expectedTotal) return false;

    var c = count.slice();
    for (var j = 0; j < c.length; j++) {
      if (c[j] >= 2) {
        c[j] -= 2;
        if (this.tryMelds(c)) return true;
        c[j] += 2;
      }
    }
    return false;
  },
  tryMelds(count) {
    var i;
    for (i = 0; i < count.length; i++) {
      if (count[i] > 0) break;
    }
    if (i >= count.length) return true;

    if (count[i] >= 3) {
      count[i] -= 3;
      if (this.tryMelds(count)) return true;
      count[i] += 3;
    }

    if (i < 27) {
      var suitStart = Math.floor(i / 9) * 9;
      var pos = i - suitStart;
      if (pos <= 6 && count[i + 1] > 0 && count[i + 2] > 0) {
        count[i]--;
        count[i + 1]--;
        count[i + 2]--;
        if (this.tryMelds(count)) return true;
        count[i]++;
        count[i + 1]++;
        count[i + 2]++;
      }
    }

    return false;
  },
  nextRound() {
    wx.redirectTo({ url: '/pages/camera/index' });
  },
  goHome() {
    wx.reLaunch({ url: '/pages/index/index' });
  }
}
</script>
<page>
  <view class="container">
    <view ink:if="{{dingqueName}}" class="dingque-badge">
      <text class="dingque-text">定缺: {{dingqueName}}</text>
    </view>

    <view ink:if="{{mode === 'error'}}">
      <text class="title">⚠️ 牌数异常</text>
      <text class="error-text">当前手牌 {{handCount}} 张，需要13或14张</text>
      <button class="action-btn primary" bindtap="nextRound">重新拍照</button>
    </view>

    <view ink:if="{{mode === 'listen'}}">
      <text class="title">🀄 听牌提示</text>
      <view class="listen-list" ink:if="{{listenTiles.length > 0}}">
        <view ink:for="{{listenTiles}}" class="listen-item">
          <text class="tile-name">{{item.name}}</text>
        </view>
      </view>
      <text class="empty-text" ink:if="{{listenTiles.length === 0}}">未听牌</text>
    </view>

    <view ink:if="{{mode === 'suggest'}}">
      <text class="title">🀄 出牌建议</text>
      <view class="best-card" ink:if="{{bestSuggestion}}">
        <view ink:if="{{bestSuggestion.isDingque}}" class="dingque-tag">定缺必打</view>
        <text class="best-label">建议打</text>
        <text class="best-tile">{{bestSuggestion.discardName}}</text>
        <text class="best-listen">听: {{bestSuggestion.listenNames}}</text>
      </view>
      <view class="alt-list" ink:if="{{alternatives.length > 0}}">
        <text class="alt-title">其他选择</text>
        <view ink:for="{{alternatives}}" class="alt-item">
          <text ink:if="{{item.isDingque}}" class="dingque-mark">*</text>
          <text class="alt-text">打{{item.discardName}} → 听{{item.listenNames}}</text>
        </view>
      </view>
      <text class="empty-text" ink:if="{{!bestSuggestion}}">无法胡牌</text>
    </view>

    <view class="bottom-actions">
      <button class="action-btn secondary" bindtap="goHome">切换规则</button>
      <button class="action-btn primary" bindtap="nextRound">下一轮拍照</button>
    </view>
  </view>
</page>
<style>
.container {
  display: flex;
  flex-direction: column;
  padding: 20px;
  background-color: #000;
  height: 100vh;
  box-sizing: border-box;
}
.dingque-badge {
  margin-bottom: 12px;
  padding: 4px 12px;
  background-color: rgba(255, 165, 0, 0.2);
  border-radius: 8px;
  align-self: flex-start;
}
.dingque-text {
  font-size: 14px;
  color: #FFA500;
}
.title {
  font-size: 22px;
  color: #40FF5E;
  font-weight: bold;
  margin-bottom: 16px;
}
.error-text {
  font-size: 16px;
  color: rgba(255, 100, 100, 0.8);
  margin-bottom: 20px;
}
.listen-list {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}
.listen-item {
  background-color: rgba(64, 255, 94, 0.15);
  border: 1px solid rgba(64, 255, 94, 0.4);
  border-radius: 8px;
  padding: 8px 14px;
  margin: 4px;
}
.tile-name {
  font-size: 18px;
  color: #40FF5E;
  font-weight: bold;
}
.empty-text {
  font-size: 16px;
  color: rgba(64, 255, 94, 0.4);
  margin-top: 20px;
}
.best-card {
  background-color: rgba(64, 255, 94, 0.15);
  border: 2px solid #40FF5E;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 16px;
  position: relative;
}
.dingque-tag {
  position: absolute;
  top: -10px;
  right: 16px;
  background-color: #FFA500;
  color: #000;
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 4px;
  font-weight: bold;
}
.best-label {
  font-size: 14px;
  color: rgba(64, 255, 94, 0.6);
}
.best-tile {
  font-size: 28px;
  color: #40FF5E;
  font-weight: bold;
  display: block;
  margin: 8px 0;
}
.best-listen {
  font-size: 16px;
  color: #40FF5E;
}
.alt-title {
  font-size: 14px;
  color: rgba(64, 255, 94, 0.5);
  margin-bottom: 8px;
}
.alt-list {
  margin-bottom: 16px;
}
.alt-item {
  background-color: rgba(64, 255, 94, 0.05);
  border-radius: 8px;
  padding: 8px 12px;
  margin-bottom: 4px;
  display: flex;
  align-items: center;
}
.dingque-mark {
  color: #FFA500;
  font-size: 16px;
  margin-right: 8px;
}
.alt-text {
  font-size: 14px;
  color: rgba(64, 255, 94, 0.7);
}
.bottom-actions {
  display: flex;
  flex-direction: row;
  margin-top: auto;
  padding-top: 16px;
}
.action-btn {
  flex: 1;
  height: 44px;
  border-radius: 12px;
  font-size: 16px;
  font-weight: bold;
  text-align: center;
  line-height: 44px;
  margin: 0 4px;
}
.action-btn.primary {
  background-color: #40FF5E;
  color: #000;
}
.action-btn.secondary {
  background-color: rgba(64, 255, 94, 0.15);
  color: #40FF5E;
  border: 1px solid rgba(64, 255, 94, 0.3);
}
</style>
