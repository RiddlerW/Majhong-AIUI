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
var A = require('../../lib/mahjong-analyzer.js');

export default {
  data: {
    handCount: 0,
    mode: 'listen',
    shanten: 0,
    shantenLabel: '',
    bestSuggestion: null,
    alternatives: [],
    listenTiles: [],
    dingque: '',
    dingqueName: '',
    fanResult: null,
    errorDetail: ''
  },
  onLoad() {
    var app = getApp();
    var handTiles = (app && app.globalData.handTiles) || [];
    var pengTiles = (app && app.globalData.pengTiles) || [];
    var gangTiles = (app && app.globalData.gangTiles) || [];
    var ruleType = (app && app.globalData.ruleType) || wx.getStorageSync('ruleType') || 'xz';
    var dingque = (app && app.globalData.dingque) || wx.getStorageSync('dingque') || '';

    var analysis = A.getAnalysis(handTiles, pengTiles, gangTiles, ruleType, dingque);

    this.setData({
      handCount: analysis.handCount,
      mode: analysis.mode,
      shanten: analysis.shanten,
      shantenLabel: analysis.shantenLabel || '',
      bestSuggestion: analysis.bestSuggestion,
      alternatives: analysis.alternatives,
      listenTiles: analysis.listenTiles,
      dingque: analysis.dingque,
      dingqueName: analysis.dingqueName,
      fanResult: analysis.fanResult || null,
      errorDetail: analysis.errorDetail || ''
    });
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
      <text class="error-text">当前手牌 {{handCount}} 张，{{errorDetail || '数量异常'}}</text>
      <button class="action-btn primary" bindtap="nextRound">重新拍照</button>
    </view>

    <view ink:if="{{mode === 'win'}}">
      <text class="title">🎉 胡牌！</text>
      <view ink:if="{{fanResult}}" class="fan-card">
        <text class="fan-total">{{fanResult.totalFan}}番 · {{fanResult.fanName}}</text>
        <view class="fan-list">
          <text ink:for="{{fanResult.fans}}" class="fan-item">{{item.name}}({{item.fan}}番)</text>
        </view>
      </view>
    </view>

    <view ink:if="{{mode === 'listen'}}">
      <text class="title">🀄 听牌</text>
      <view class="listen-list" ink:if="{{listenTiles.length > 0}}">
        <view ink:for="{{listenTiles}}" class="listen-item">
          <text class="tile-name">{{item.name}}</text>
          <text class="tile-remaining">({{item.remaining}}张)</text>
          <text ink:if="{{item.fanResult}}" class="tile-fan">{{item.fanResult.totalFan}}番</text>
        </view>
      </view>
      <text class="empty-text" ink:if="{{listenTiles.length === 0}}">未听牌</text>
    </view>

    <view ink:if="{{mode === 'shanten'}}">
      <text class="title">🀄 {{shantenLabel}}</text>
      <view ink:if="{{alternatives.length > 0}}" class="suggestion-list">
        <view ink:for="{{alternatives}}" class="suggestion-item">
          <view ink:if="{{item.isDingque}}" class="dingque-mark">定缺</view>
          <text class="suggestion-discard">打{{item.discardName}}</text>
          <text class="suggestion-shanten">{{item.shantenAfter === 0 ? '→听牌' : '→' + item.shantenAfter + '进听'}}</text>
          <text class="suggestion-remaining" ink:if="{{item.totalRemaining > 0}}">进张{{item.totalRemaining}}</text>
        </view>
      </view>
    </view>

    <view ink:if="{{mode === 'suggest'}}">
      <text class="title">🀄 出牌建议</text>
      <view class="best-card" ink:if="{{bestSuggestion}}">
        <view ink:if="{{bestSuggestion.isDingque}}" class="dingque-tag">定缺必打</view>
        <text class="best-label">建议打</text>
        <text class="best-tile">{{bestSuggestion.discardName}}</text>
        <text class="best-listen" ink:if="{{bestSuggestion.shantenAfter === 0}}">听: {{bestSuggestion.listenNames}}</text>
        <text class="best-shanten" ink:if="{{bestSuggestion.shantenAfter > 0}}">{{bestSuggestion.shantenAfter}}进听</text>
        <text class="best-remaining" ink:if="{{bestSuggestion.totalRemaining > 0}}">有效进张: {{bestSuggestion.totalRemaining}}</text>
      </view>
      <view class="alt-list" ink:if="{{alternatives.length > 0}}">
        <text class="alt-title">其他选择</text>
        <view ink:for="{{alternatives}}" class="alt-item">
          <text ink:if="{{item.isDingque}}" class="dingque-mark">*</text>
          <text class="alt-text">打{{item.discardName}}</text>
          <text class="alt-listen" ink:if="{{item.shantenAfter === 0}}">→听{{item.listenNames}}</text>
          <text class="alt-shanten" ink:if="{{item.shantenAfter > 0}}">→{{item.shantenAfter}}进听</text>
          <text class="alt-remaining" ink:if="{{item.totalRemaining > 0}}">进张{{item.totalRemaining}}</text>
        </view>
      </view>
      <text class="empty-text" ink:if="{{!bestSuggestion}}">无法优化</text>
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
.fan-card {
  background-color: rgba(255, 215, 0, 0.15);
  border: 1px solid rgba(255, 215, 0, 0.4);
  border-radius: 12px;
  padding: 12px 16px;
  margin-bottom: 16px;
}
.fan-total {
  font-size: 20px;
  color: #FFD700;
  font-weight: bold;
  display: block;
  margin-bottom: 8px;
}
.fan-list {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}
.fan-item {
  font-size: 14px;
  color: rgba(255, 215, 0, 0.7);
  background: rgba(255, 215, 0, 0.1);
  border-radius: 6px;
  padding: 4px 8px;
  margin: 2px 4px 2px 0;
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
  display: flex;
  align-items: center;
}
.tile-name {
  font-size: 18px;
  color: #40FF5E;
  font-weight: bold;
}
.tile-remaining {
  font-size: 12px;
  color: rgba(64, 255, 94, 0.5);
  margin-left: 4px;
}
.tile-fan {
  font-size: 12px;
  color: #FFD700;
  margin-left: 6px;
  background: rgba(255, 215, 0, 0.15);
  padding: 1px 4px;
  border-radius: 3px;
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
  display: block;
}
.best-shanten {
  font-size: 16px;
  color: #FFA500;
  display: block;
}
.best-remaining {
  font-size: 14px;
  color: rgba(64, 255, 94, 0.6);
  display: block;
  margin-top: 4px;
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
  flex-wrap: wrap;
}
.dingque-mark {
  color: #FFA500;
  font-size: 12px;
  margin-right: 6px;
  background: rgba(255, 165, 0, 0.2);
  padding: 1px 4px;
  border-radius: 3px;
}
.alt-text {
  font-size: 14px;
  color: rgba(64, 255, 94, 0.9);
  font-weight: bold;
}
.alt-listen {
  font-size: 13px;
  color: rgba(64, 255, 94, 0.7);
  margin-left: 6px;
}
.alt-shanten {
  font-size: 13px;
  color: #FFA500;
  margin-left: 6px;
}
.alt-remaining {
  font-size: 12px;
  color: rgba(64, 255, 94, 0.5);
  margin-left: 6px;
}
.suggestion-list {
  width: 100%;
}
.suggestion-item {
  background-color: rgba(64, 255, 94, 0.05);
  border-radius: 8px;
  padding: 10px 14px;
  margin-bottom: 6px;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
}
.suggestion-discard {
  font-size: 16px;
  color: #40FF5E;
  font-weight: bold;
}
.suggestion-shanten {
  font-size: 14px;
  color: #FFA500;
  margin-left: 8px;
}
.suggestion-remaining {
  font-size: 12px;
  color: rgba(64, 255, 94, 0.5);
  margin-left: 8px;
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
