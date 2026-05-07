export default {
  onLaunch() {
    console.log('Mahjong Assistant Launch');
  },
  onShow() {
    console.log('Mahjong Assistant Show');
  },
  onHide() {
    console.log('Mahjong Assistant Hide');
  },
  globalData: {
    ruleType: 'xz',
    handTiles: [],
    pengTiles: [],
    gangTiles: [],
    lastRecognition: null
  }
}
