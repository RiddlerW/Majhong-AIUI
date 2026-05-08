<script def>
{
  "navigationBarTitleText": "设置",
  "description": "配置OCR识别API密钥",
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
    apiKey: '',
    keyStatus: '未配置',
    statusColor: 'rgba(255, 100, 100, 0.8)'
  },
  onLoad() {
    var savedKey = wx.getStorageSync('minimaxApiKey') || '';
    this.setData({
      apiKey: savedKey,
      keyStatus: savedKey ? '已配置' : '未配置',
      statusColor: savedKey ? 'rgba(64, 255, 94, 0.8)' : 'rgba(255, 100, 100, 0.8)'
    });
  },
  onKeyInput(e) {
    this.setData({ apiKey: e.detail.value });
  },
  saveKey() {
    var key = this.data.apiKey.trim();
    if (!key) {
      wx.removeStorageSync('minimaxApiKey');
      this.setData({
        keyStatus: '未配置',
        statusColor: 'rgba(255, 100, 100, 0.8)'
      });
      wx.showToast({ title: '已清除API Key', icon: 'none' });
      return;
    }
    wx.setStorageSync('minimaxApiKey', key);
    this.setData({
      keyStatus: '已配置',
      statusColor: 'rgba(64, 255, 94, 0.8)'
    });
    wx.showToast({ title: '保存成功', icon: 'success' });
  },
  goBack() {
    wx.navigateBack();
  }
}
</script>
<page>
  <view class="container">
    <text class="title">⚙️ 设置</text>

    <view class="section">
      <text class="section-title">OCR 识别服务</text>
      <view class="status-row">
        <text class="status-label">Minimax API Key</text>
        <text class="status-badge" style="color: {{statusColor}}">{{keyStatus}}</text>
      </view>
      <input
        class="key-input"
        placeholder="请输入 Minimax API Key"
        value="{{apiKey}}"
        bindinput="onKeyInput"
        type="text"
        password="true"
      />
      <text class="hint-text">用于拍照识别麻将牌，Key 将保存在本地</text>
      <button class="save-btn" bindtap="saveKey">保存</button>
    </view>

    <button class="back-btn" bindtap="goBack">← 返回</button>
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
  margin-bottom: 24px;
}
.section {
  width: 100%;
  padding: 20px;
  border-radius: 16px;
  border: 2px solid rgba(64, 255, 94, 0.2);
  background-color: rgba(64, 255, 94, 0.05);
  margin-bottom: 20px;
}
.section-title {
  font-size: 18px;
  color: #40FF5E;
  font-weight: bold;
  margin-bottom: 16px;
}
.status-row {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.status-label {
  font-size: 14px;
  color: rgba(64, 255, 94, 0.6);
}
.status-badge {
  font-size: 14px;
  font-weight: bold;
}
.key-input {
  width: 100%;
  height: 44px;
  border-radius: 10px;
  border: 1px solid rgba(64, 255, 94, 0.3);
  background-color: rgba(64, 255, 94, 0.08);
  color: #40FF5E;
  font-size: 14px;
  padding: 0 12px;
  margin-bottom: 8px;
  box-sizing: border-box;
}
.hint-text {
  font-size: 12px;
  color: rgba(64, 255, 94, 0.4);
  margin-bottom: 16px;
}
.save-btn {
  width: 100%;
  height: 44px;
  border-radius: 10px;
  background-color: #40FF5E;
  color: #000;
  font-size: 16px;
  font-weight: bold;
  text-align: center;
  line-height: 44px;
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
