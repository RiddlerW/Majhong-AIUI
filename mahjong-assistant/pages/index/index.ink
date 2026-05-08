<script def>
{
  "navigationBarTitleText": "麻将助手",
  "description": "选择麻将规则类型和定缺",
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

export default {
  data: {
    step: 'rule',
    rules: [
      { id: 'xz', name: '血战到底', desc: '四川麻将，只有万条筒', selected: true },
      { id: 'xl', name: '血流成河', desc: '胡牌后继续摸打', selected: false },
      { id: 'gb', name: '国标麻将', desc: '8番起胡，81种番型', selected: false }
    ],
    selectedRuleIndex: 0,
    suits: [
      { id: 'wan', name: '万', char: '🀇', selected: false },
      { id: 'tiao', name: '条', char: '🀙', selected: false },
      { id: 'tong', name: '筒', char: '🀐', selected: false }
    ],
    selectedSuitIndex: -1
  },
  onLoad() {
    var savedRule = wx.getStorageSync('ruleType') || 'xz';
    var savedSuit = wx.getStorageSync('dingque') || '';
    var rules = this.data.rules;
    var suits = this.data.suits;
    var ruleIdx = 0;
    var suitIdx = -1;
    for (var i = 0; i < rules.length; i++) {
      rules[i].selected = (rules[i].id === savedRule);
      if (rules[i].id === savedRule) ruleIdx = i;
    }
    for (var i = 0; i < suits.length; i++) {
      suits[i].selected = (suits[i].id === savedSuit);
      if (suits[i].id === savedSuit) suitIdx = i;
    }
    this.setData({ 
      rules: rules, 
      selectedRuleIndex: ruleIdx,
      suits: suits,
      selectedSuitIndex: suitIdx 
    });
  },
  selectRule(e) {
    var idx = e.currentTarget.dataset.index;
    var rules = this.data.rules;
    for (var i = 0; i < rules.length; i++) {
      rules[i].selected = (i == idx);
    }
    this.setData({ rules: rules, selectedRuleIndex: idx });
  },
  selectSuit(e) {
    var idx = e.currentTarget.dataset.index;
    var suits = this.data.suits;
    for (var i = 0; i < suits.length; i++) {
      suits[i].selected = (i == idx);
    }
    this.setData({ suits: suits, selectedSuitIndex: idx });
  },
  nextStep() {
    var ruleId = this.data.rules[this.data.selectedRuleIndex].id;
    if (ruleId === 'gb') {
      this.startGame(ruleId, '');
    } else {
      this.setData({ step: 'dingque' });
    }
  },
  startGame(ruleId, dingque) {
    wx.setStorageSync('ruleType', ruleId);
    wx.setStorageSync('dingque', dingque);
    var app = getApp();
    if (app) {
      app.globalData.ruleType = ruleId;
      app.globalData.dingque = dingque;
      app.globalData.handTiles = [];
      app.globalData.pengTiles = [];
      app.globalData.gangTiles = [];
    }
    wx.navigateTo({ url: '/pages/camera/index' });
  },
  confirmDingque() {
    var ruleId = this.data.rules[this.data.selectedRuleIndex].id;
    var dingque = this.data.suits[this.data.selectedSuitIndex].id;
    this.startGame(ruleId, dingque);
  },
  backToRule() {
    this.setData({ step: 'rule' });
  }
}
</script>
<page>
  <view class="container">
    <view ink:if="{{step === 'rule'}}">
      <text class="title">🀄 麻将助手</text>
      <text class="subtitle">选择规则</text>
      <view class="rule-list">
        <view ink:for="{{rules}}" class="rule-card {{item.selected ? 'selected' : ''}}" bindtap="selectRule" data-index="{{index}}">
          <text class="rule-name">{{item.name}}</text>
          <text class="rule-desc">{{item.desc}}</text>
          <text class="rule-check">{{item.selected ? '✓' : ''}}</text>
        </view>
      </view>
      <button class="start-btn" bindtap="nextStep">确认开始</button>
    </view>

    <view ink:if="{{step === 'dingque'}}">
      <text class="title">🎯 选择定缺</text>
      <text class="subtitle">选择你要缺的花色</text>
      <view class="dingque-list">
        <view ink:for="{{suits}}" class="dingque-card {{item.selected ? 'selected' : ''}}" bindtap="selectSuit" data-index="{{index}}">
          <text class="dingque-char">{{item.char}}</text>
          <text class="dingque-name">{{item.name}}</text>
        </view>
      </view>
      <button class="back-btn" bindtap="backToRule">← 返回</button>
      <button class="start-btn" bindtap="confirmDingque" ink:if="{{selectedSuitIndex >= 0}}">确认定缺</button>
    </view>
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
.dingque-list {
  width: 100%;
  display: flex;
  flex-direction: row;
  justify-content: space-around;
}
.dingque-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  border-radius: 16px;
  border: 2px solid rgba(64, 255, 94, 0.2);
  background-color: rgba(64, 255, 94, 0.05);
  width: 120px;
}
.dingque-card.selected {
  border-color: #40FF5E;
  background-color: rgba(64, 255, 94, 0.15);
}
.dingque-char {
  font-size: 40px;
  margin-bottom: 8px;
}
.dingque-name {
  font-size: 18px;
  color: #40FF5E;
  font-weight: bold;
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
.back-btn {
  margin-top: 20px;
  width: 100%;
  height: 44px;
  border-radius: 12px;
  background-color: rgba(64, 255, 94, 0.1);
  color: #40FF5E;
  font-size: 16px;
  text-align: center;
  line-height: 44px;
}
</style>
