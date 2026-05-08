(function(root, factory) {
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = factory();
  } else {
    root.MahjongFan = factory();
  }
})(typeof self !== 'undefined' ? self : this, function() {

  var C = (typeof MahjongConstants !== 'undefined') ? MahjongConstants
        : (typeof require !== 'undefined') ? require('./mahjong-constants.js') : null;

  function calculateFan(handTiles, pengTiles, gangTiles, winTile, ruleType, dingque, isZimo, isGangshang) {
    if (!C) return { fans: [], totalFan: 0, fanName: '未知' };

    var count = C.tilesToCount(handTiles);
    if (winTile >= 0 && winTile < C.TILE_COUNT) {
      count[winTile]++;
    }

    var allTiles = handTiles.slice();
    if (winTile >= 0) allTiles.push(winTile);
    var allCount = C.tilesToCount(allTiles);

    var pengGroups = pengTiles || [];
    var gangGroups = gangTiles || [];
    var meldCount = pengGroups.length + gangGroups.length;

    var fans = [];

    if (ruleType === 'xz' || ruleType === 'xl') {
      fans = _calculateXZFan(allCount, pengGroups, gangGroups, meldCount, dingque, isZimo, isGangshang, ruleType);
    } else if (ruleType === 'gb') {
      fans = _calculateGBFan(allCount, pengGroups, gangGroups, meldCount, isZimo);
    }

    var totalFan = 0;
    for (var i = 0; i < fans.length; i++) {
      totalFan += fans[i].fan;
    }

    var fanName = _fanToName(totalFan, ruleType);

    return {
      fans: fans,
      totalFan: totalFan,
      fanName: fanName
    };
  }

  function _calculateXZFan(allCount, pengGroups, gangGroups, meldCount, dingque, isZimo, isGangshang, ruleType) {
    var fans = [];
    var isQingyise = _checkQingyise(allCount, pengGroups, gangGroups);
    var isDuiduihu = _checkDuiduihu(allCount, pengGroups, gangGroups, meldCount);
    var isQidui = _checkQidui(allCount);
    var isJingoudiao = _checkJingoudiao(allCount, pengGroups, gangGroups, meldCount);
    var isMenqing = (pengGroups.length === 0 && gangGroups.length === 0);
    var isLongQidui = false;
    var isQingQidui = false;
    var isQingLongQidui = false;

    if (isQidui) {
      isLongQidui = _checkLongQidui(allCount);
      if (isQingyise) {
        isQingQidui = true;
        if (isLongQidui) {
          isQingLongQidui = true;
        }
      }
    }

    if (isQingLongQidui) {
      fans.push({ name: '清龙七对', fan: 16 });
    } else if (isQingQidui) {
      fans.push({ name: '清七对', fan: 8 });
    } else if (isLongQidui) {
      fans.push({ name: '龙七对', fan: 4 });
    } else if (isQidui) {
      fans.push({ name: '七对', fan: 2 });
    }

    if (isQingyise && !isQingQidui && !isQingLongQidui) {
      fans.push({ name: '清一色', fan: 4 });
    }

    if (isDuiduihu && !isQidui) {
      fans.push({ name: '对对胡', fan: 2 });
    }

    if (isJingoudiao) {
      fans.push({ name: '金钩钓', fan: 4 });
    }

    if (isZimo) {
      fans.push({ name: '自摸', fan: 1 });
    }

    if (isGangshang === 'hua') {
      fans.push({ name: '杠上花', fan: 1 });
    } else if (isGangshang === 'pao') {
      fans.push({ name: '杠上炮', fan: 1 });
    }

    if (fans.length === 0) {
      fans.push({ name: '平胡', fan: 1 });
    }

    if (ruleType === 'xl') {
      var genCount = _checkGen(allCount, pengGroups, gangGroups);
      for (var g = 0; g < genCount; g++) {
        fans.push({ name: '根', fan: 1 });
      }
    }

    return fans;
  }

  function _checkQingyise(allCount, pengGroups, gangGroups) {
    var hasWan = false, hasTiao = false, hasTong = false;
    for (var i = 0; i < allCount.length; i++) {
      if (allCount[i] > 0) {
        if (i <= 8) hasWan = true;
        else if (i <= 17) hasTiao = true;
        else if (i <= 26) hasTong = true;
        else return false;
      }
    }
    for (var i = 0; i < pengGroups.length; i++) {
      var t = pengGroups[i][0];
      if (t <= 8) hasWan = true;
      else if (t <= 17) hasTiao = true;
      else if (t <= 26) hasTong = true;
      else return false;
    }
    for (var i = 0; i < gangGroups.length; i++) {
      var t = gangGroups[i][0];
      if (t <= 8) hasWan = true;
      else if (t <= 17) hasTiao = true;
      else if (t <= 26) hasTong = true;
      else return false;
    }
    return (hasWan && !hasTiao && !hasTong) || (!hasWan && hasTiao && !hasTong) || (!hasWan && !hasTiao && hasTong);
  }

  function _checkDuiduihu(allCount, pengGroups, gangGroups, meldCount) {
    for (var i = 0; i < allCount.length; i++) {
      if (allCount[i] > 0 && allCount[i] !== 2 && allCount[i] !== 3) {
        return false;
      }
    }
    return true;
  }

  function _checkQidui(allCount) {
    var total = 0;
    var pairs = 0;
    for (var i = 0; i < allCount.length; i++) {
      total += allCount[i];
      if (allCount[i] === 2) pairs++;
      else if (allCount[i] === 4) pairs += 2;
      else if (allCount[i] !== 0) return false;
    }
    return total === 14 && pairs === 7;
  }

  function _checkLongQidui(allCount) {
    for (var i = 0; i < allCount.length; i++) {
      if (allCount[i] === 4) return true;
    }
    return false;
  }

  function _checkJingoudiao(allCount, pengGroups, gangGroups, meldCount) {
    if (meldCount === 0) return false;
    var pairCount = 0;
    for (var i = 0; i < allCount.length; i++) {
      if (allCount[i] === 2) pairCount++;
    }
    return pairCount === 1;
  }

  function _checkGen(allCount, pengGroups, gangGroups) {
    var genCount = 0;
    for (var i = 0; i < allCount.length; i++) {
      if (allCount[i] === 4) genCount++;
    }
    for (var i = 0; i < gangGroups.length; i++) {
      genCount++;
    }
    return genCount;
  }

  function _calculateGBFan(allCount, pengGroups, gangGroups, meldCount, isZimo) {
    var fans = [];

    var isQingyise = _checkQingyise(allCount, pengGroups, gangGroups);
    var isZiyise = _checkZiyise(allCount, pengGroups, gangGroups);
    var isDuiduihu = _checkDuiduihu(allCount, pengGroups, gangGroups, meldCount);
    var isQidui = _checkQidui(allCount);
    var isMenqing = (pengGroups.length === 0 && gangGroups.length === 0);
    var isPengpenghu = _checkDuiduihu(allCount, pengGroups, gangGroups, meldCount);
    var isYitiaolong = _checkYitiaolong(allCount);
    var isShisanyao = _checkShisanyao(allCount);

    if (isShisanyao) {
      fans.push({ name: '十三幺', fan: 88 });
    }

    if (isQingyise) {
      fans.push({ name: '清一色', fan: 24 });
    }

    if (isZiyise) {
      fans.push({ name: '字一色', fan: 64 });
    }

    if (isQidui) {
      fans.push({ name: '七对', fan: 24 });
    }

    if (isPengpenghu && !isZiyise) {
      fans.push({ name: '碰碰胡', fan: 6 });
    }

    if (isYitiaolong && isQingyise) {
      fans.push({ name: '清龙', fan: 16 });
    } else if (isYitiaolong) {
      fans.push({ name: '一条龙', fan: 16 });
    }

    if (isMenqing && isZimo) {
      fans.push({ name: '门前清自摸', fan: 1 });
    } else if (isMenqing) {
      fans.push({ name: '门前清', fan: 2 });
    }

    if (isZimo && !isMenqing) {
      fans.push({ name: '自摸', fan: 1 });
    }

    if (fans.length === 0) {
      fans.push({ name: '平胡', fan: 1 });
    }

    return fans;
  }

  function _checkZiyise(allCount, pengGroups, gangGroups) {
    for (var i = 0; i < allCount.length; i++) {
      if (allCount[i] > 0 && i < 27) return false;
    }
    for (var i = 0; i < pengGroups.length; i++) {
      if (pengGroups[i][0] < 27) return false;
    }
    for (var i = 0; i < gangGroups.length; i++) {
      if (gangGroups[i][0] < 27) return false;
    }
    return true;
  }

  function _checkYitiaolong(allCount) {
    for (var suit = 0; suit < 3; suit++) {
      var start = suit * 9;
      var complete = true;
      for (var i = start; i < start + 9; i++) {
        if (allCount[i] < 1) { complete = false; break; }
      }
      if (complete) return true;
    }
    return false;
  }

  function _checkShisanyao(allCount) {
    var terminals = [0, 8, 9, 17, 18, 26, 27, 28, 29, 30, 31, 32, 33];
    var kinds = 0;
    var hasPair = false;
    for (var i = 0; i < terminals.length; i++) {
      if (allCount[terminals[i]] >= 1) kinds++;
      if (allCount[terminals[i]] >= 2) hasPair = true;
    }
    return kinds === 13 && hasPair;
  }

  function _fanToName(totalFan, ruleType) {
    if (ruleType === 'xz' || ruleType === 'xl') {
      if (totalFan >= 16) return '极品';
      if (totalFan >= 8) return '大胡';
      if (totalFan >= 4) return '中胡';
      if (totalFan >= 2) return '小胡';
      return '平胡';
    } else if (ruleType === 'gb') {
      if (totalFan >= 88) return '满贯';
      if (totalFan >= 64) return '跳满';
      if (totalFan >= 32) return '倍满';
      if (totalFan >= 24) return '三倍满';
      if (totalFan >= 16) return '两倍满';
      if (totalFan >= 8) return '满贯';
      if (totalFan >= 6) return '跳满';
      if (totalFan >= 4) return '倍满';
      if (totalFan >= 2) return '两番';
      return '一番';
    }
    return totalFan + '番';
  }

  function getFanForListen(handTiles, pengTiles, gangTiles, listenTile, ruleType, dingque) {
    return calculateFan(handTiles, pengTiles, gangTiles, listenTile, ruleType, dingque, true, null);
  }

  return {
    calculateFan: calculateFan,
    getFanForListen: getFanForListen
  };
});
