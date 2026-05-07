<script def>
{
  "navigationBarTitleText": "确认手牌",
  "description": "确认或调整识别到的手牌",
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
    handTiles: [],
    handGroups: [],
    pengGroups: [],
    gangGroups: [],
    handCount: 0,
    isAdjusting: false,
    adjustIndex: 0,
    adjustName: '',
    adjustCount: 0,
    allTiles: []
  },
  onLoad() {
    var app = getApp();
    var handTiles = (app && app.globalData.handTiles) || [];
    var pengTiles = (app && app.globalData.pengTiles) || [];
    var gangTiles = (app && app.globalData.gangTiles) || [];

    this.setData({
      handTiles: handTiles,
      handGroups: this.buildHandGroups(handTiles),
      pengGroups: this.buildPengGangGroups(pengTiles, '碰'),
      gangGroups: this.buildPengGangGroups(gangTiles, '杠'),
      handCount: handTiles.length
    });

    var ruleType = (app && app.globalData.ruleType) || wx.getStorageSync('ruleType') || 'xz';
    var range = C.getRuleTileRange(ruleType);
    var allTiles = [];
    for (var i = range.min; i <= range.max; i++) {
      allTiles.push({ index: i, name: C.getTileShortName(i) });
    }
    this.setData({ allTiles: allTiles });
  },
  buildHandGroups(tiles) {
    var count = C.tilesToCount(tiles);
    var groups = [];
    for (var i = 0; i < count.length; i++) {
      if (count[i] > 0) {
        groups.push({
          tileIndex: i,
          name: C.getTileShortName(i),
          count: count[i]
        });
      }
    }
    return groups;
  },
  buildPengGangGroups(groups, label) {
    var result = [];
    for (var i = 0; i < groups.length; i++) {
      if (groups[i] && groups[i].length > 0) {
        result.push({
          name: C.getTileShortName(groups[i][0]),
          count: groups[i].length,
          label: label
        });
      }
    }
    return result;
  },
  retakePhoto() {
    wx.navigateBack();
  },
  enterAdjust() {
    this.setData({ isAdjusting: true, adjustIndex: 0 });
    this.updateAdjustDisplay(0);
  },
  updateAdjustDisplay(idx) {
    var count = C.tilesToCount(this.data.handTiles);
    var tileIdx = this.data.allTiles[idx] ? this.data.allTiles[idx].index : 0;
    this.setData({
      adjustIndex: idx,
      adjustName: C.getTileShortName(tileIdx),
      adjustCount: count[tileIdx] || 0
    });
  },
  prevTile() {
    var idx = this.data.adjustIndex - 1;
    if (idx < 0) idx = this.data.allTiles.length - 1;
    this.updateAdjustDisplay(idx);
  },
  nextTile() {
    var idx = this.data.adjustIndex + 1;
    if (idx >= this.data.allTiles.length) idx = 0;
    this.updateAdjustDisplay(idx);
  },
  addTile() {
    var tileIdx = this.data.allTiles[this.data.adjustIndex].index;
    var tiles = this.data.handTiles.slice();
    tiles.push(tileIdx);
    tiles.sort(function(a, b) { return a - b; });
    this.setData({
      handTiles: tiles,
      handGroups: this.buildHandGroups(tiles),
      handCount: tiles.length,
      adjustCount: (this.data.adjustCount || 0) + 1
    });
  },
  removeTile() {
    var tileIdx = this.data.allTiles[this.data.adjustIndex].index;
    var tiles = this.data.handTiles.slice();
    var found = false;
    for (var i = tiles.length - 1; i >= 0; i--) {
      if (tiles[i] === tileIdx) {
        tiles.splice(i, 1);
        found = true;
        break;
      }
    }
    if (found) {
      tiles.sort(function(a, b) { return a - b; });
      this.setData({
        handTiles: tiles,
        handGroups: this.buildHandGroups(tiles),
        handCount: tiles.length,
        adjustCount: this.data.adjustCount - 1
      });
    }
  },
  finishAdjust() {
    var app = getApp();
    if (app) {
      app.globalData.handTiles = this.data.handTiles;
    }
    this.setData({ isAdjusting: false });
  },
  confirmAndAnalyze() {
    var app = getApp();
    if (app) {
      app.globalData.handTiles = this.data.handTiles;
    }
    wx.navigateTo({ url: '/pages/result/result' });
  }
}
</script>
<page>
  <view class="container" ink:if="{{!isAdjusting}}">
    <text class="title">识别结果确认</text>
    <view class="section">
      <text class="section-label">手牌 ({{handCount}}张)</text>
      <view class="tile-list">
        <view ink:for="{{handGroups}}" class="tile-item">
          <text class="tile-name">{{item.name}}</text>
          <text class="tile-count">×{{item.count}}</text>
        </view>
      </view>
    </view>
    <view class="section" ink:if="{{pengGroups.length > 0}}">
      <text class="section-label">碰牌</text>
      <view class="tile-list">
        <view ink:for="{{pengGroups}}" class="tile-item">
          <text class="tile-name">{{item.name}}×{{item.count}}({{item.label}})</text>
        </view>
      </view>
    </view>
    <view class="section" ink:if="{{gangGroups.length > 0}}">
      <text class="section-label">杠牌</text>
      <view class="tile-list">
        <view ink:for="{{gangGroups}}" class="tile-item">
          <text class="tile-name">{{item.name}}×{{item.count}}({{item.label}})</text>
        </view>
      </view>
    </view>
    <view class="actions">
      <button class="action-btn secondary" bindtap="retakePhoto">重拍</button>
      <button class="action-btn secondary" bindtap="enterAdjust">调整</button>
      <button class="action-btn primary" bindtap="confirmAndAnalyze">确认</button>
    </view>
  </view>
  <view class="container adjust-mode" ink:if="{{isAdjusting}}">
    <text class="title">手动调整</text>
    <view class="adjust-display">
      <button class="arrow-btn" bindtap="prevTile">◀</button>
      <view class="adjust-info">
        <text class="adjust-name">{{adjustName}}</text>
        <text class="adjust-count">×{{adjustCount}}</text>
      </view>
      <button class="arrow-btn" bindtap="nextTile">▶</button>
    </view>
    <view class="adjust-actions">
      <button class="action-btn secondary" bindtap="removeTile">- 减</button>
      <button class="action-btn secondary" bindtap="addTile">+ 加</button>
    </view>
    <button class="action-btn primary finish-btn" bindtap="finishAdjust">完成调整</button>
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
.title {
  font-size: 22px;
  color: #40FF5E;
  font-weight: bold;
  margin-bottom: 16px;
}
.section {
  margin-bottom: 12px;
}
.section-label {
  font-size: 14px;
  color: rgba(64, 255, 94, 0.5);
  margin-bottom: 8px;
}
.tile-list {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}
.tile-item {
  display: flex;
  flex-direction: row;
  align-items: center;
  background-color: rgba(64, 255, 94, 0.1);
  border-radius: 8px;
  padding: 6px 10px;
  margin: 4px;
}
.tile-name {
  font-size: 16px;
  color: #40FF5E;
}
.tile-count {
  font-size: 14px;
  color: rgba(64, 255, 94, 0.6);
  margin-left: 4px;
}
.actions {
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
.adjust-display {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
  margin: 30px 0;
}
.arrow-btn {
  width: 60px;
  height: 60px;
  border-radius: 30px;
  background-color: rgba(64, 255, 94, 0.15);
  color: #40FF5E;
  font-size: 24px;
  text-align: center;
  line-height: 60px;
}
.adjust-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin: 0 30px;
}
.adjust-name {
  font-size: 32px;
  color: #40FF5E;
  font-weight: bold;
}
.adjust-count {
  font-size: 20px;
  color: rgba(64, 255, 94, 0.6);
  margin-top: 4px;
}
.adjust-actions {
  display: flex;
  flex-direction: row;
  margin-bottom: 20px;
}
.finish-btn {
  margin-top: 20px;
}
</style>
