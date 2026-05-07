<script def>
{
  "navigationBarTitleText": "麻将助手",
  "description": "选择麻将规则类型",
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
    rules: [
      { id: 'xz', name: '血战到底', desc: '四川麻将，只有万条筒', selected: true },
      { id: 'xl', name: '血流成河', desc: '胡牌后继续摸打', selected: false },
      { id: 'gb', name: '国标麻将', desc: '8番起胡，81种番型', selected: false }
    ],
    selectedIndex: 0
  },
  onLoad() {
    var saved = wx.getStorageSync('ruleType') || 'xz';
    var idx = 0;
    var rules = this.data.rules;
    for (var i = 0; i < rules.length; i++) {
      rules[i].selected = (rules[i].id === saved);
      if (rules[i].id === saved) idx = i;
    }
    this.setData({ rules: rules, selectedIndex: idx });
  },
  selectRule(e) {
    var idx = e.currentTarget.dataset.index;
    var rules = this.data.rules;
    for (var i = 0; i < rules.length; i++) {
      rules[i].selected = (i == idx);
    }
    this.setData({ rules: rules, selectedIndex: idx });
  },
  startGame() {
    var ruleId = this.data.rules[this.data.selectedIndex].id;
    wx.setStorageSync('ruleType', ruleId);
    var app = getApp();
    if (app) {
      app.globalData.ruleType = ruleId;
      app.globalData.handTiles = [];
      app.globalData.pengTiles = [];
      app.globalData.gangTiles = [];
    }
    wx.navigateTo({ url: '/pages/camera/index' });
  }
}
</script>
<page>
  <view class="container">
    <text class="title">🀄 麻将助手</text>
    <text class="subtitle">选择规则</text>
    <view class="rule-list">
      <view ink:for="{{rules}}" class="rule-card {{item.selected ? 'selected' : ''}}" bindtap="selectRule" data-index="{{index}}">
        <text class="rule-name">{{item.name}}</text>
        <text class="rule-desc">{{item.desc}}</text>
        <text class="rule-check">{{item.selected ? '✓' : ''}}</text>
      </view>
    </view>
    <button class="start-btn" bindtap="startGame">确认开始</button>
  </view>
</page>
<style>
.container {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 30px 20px;
  background-color: #000;
  height: 100vh;
  box-sizing: border-box;
}
.title {
  font-size: 28px;
  color: #40FF5E;
  font-weight: bold;
  margin-bottom: 8px;
}
.subtitle {
  font-size: 16px;
  color: rgba(64, 255, 94, 0.6);
  margin-bottom: 20px;
}
.rule-list {
  width: 100%;
}
.rule-card {
  display: flex;
  flex-direction: row;
  align-items: center;
  padding: 16px 20px;
  margin-bottom: 12px;
  border-radius: 12px;
  border: 2px solid rgba(64, 255, 94, 0.2);
  background-color: rgba(64, 255, 94, 0.05);
}
.rule-card.selected {
  border-color: #40FF5E;
  background-color: rgba(64, 255, 94, 0.15);
}
.rule-name {
  font-size: 20px;
  color: #40FF5E;
  font-weight: bold;
  flex: 1;
}
.rule-desc {
  font-size: 14px;
  color: rgba(64, 255, 94, 0.5);
  margin-left: 12px;
}
.rule-check {
  font-size: 20px;
  color: #40FF5E;
  margin-left: 8px;
}
.start-btn {
  margin-top: 20px;
  width: 100%;
  height: 50px;
  border-radius: 12px;
  background-color: #40FF5E;
  color: #000;
  font-size: 18px;
  font-weight: bold;
  text-align: center;
  line-height: 50px;
}
</style>
