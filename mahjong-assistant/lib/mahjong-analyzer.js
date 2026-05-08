(function(root, factory) {
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = factory();
  } else {
    root.MahjongAnalyzer = factory();
  }
})(typeof self !== 'undefined' ? self : this, function() {

  var TILE_COUNT = 34;

  function calculateShanten(tiles, meldCount, ruleType) {
    meldCount = meldCount || 0;
    var count = new Array(TILE_COUNT).fill(0);
    for (var i = 0; i < tiles.length; i++) {
      if (tiles[i] >= 0 && tiles[i] < TILE_COUNT) {
        count[tiles[i]]++;
      }
    }
    return calculateShantenFromCount(count, meldCount, ruleType);
  }

  function calculateShantenFromCount(count, meldCount, ruleType) {
    meldCount = meldCount || 0;
    var shantenStandard = _shantenStandardFromCount(count, meldCount);
    var shantenChiitoi = _shantenChiitoiFromCount(count);
    return Math.min(shantenStandard, shantenChiitoi);
  }

  function _shantenStandardFromCount(count, meldCount) {
    var result = { maxMelds: 0, hasPair: 0 };
    var c = count.slice();
    _decomposeRec(c, 0, 0, 0, meldCount, result);
    return 8 - meldCount * 2 - result.maxMelds * 2 - result.hasPair;
  }

  function _decomposeRec(count, pos, melds, hasPair, meldCount, result) {
    while (pos < TILE_COUNT && count[pos] === 0) pos++;
    if (pos >= TILE_COUNT) {
      var score = melds * 2 + hasPair;
      var bestScore = result.maxMelds * 2 + result.hasPair;
      if (score > bestScore) {
        result.maxMelds = melds;
        result.hasPair = hasPair;
      }
      return;
    }

    if (count[pos] >= 2 && hasPair === 0) {
      count[pos] -= 2;
      _decomposeRec(count, pos, melds, 1, meldCount, result);
      count[pos] += 2;
    }

    if (count[pos] >= 3) {
      count[pos] -= 3;
      _decomposeRec(count, pos, melds + 1, hasPair, meldCount, result);
      count[pos] += 3;
    }

    if (pos < 27) {
      var suitStart = Math.floor(pos / 9) * 9;
      var relPos = pos - suitStart;
      if (relPos <= 6 && count[pos + 1] > 0 && count[pos + 2] > 0) {
        count[pos]--;
        count[pos + 1]--;
        count[pos + 2]--;
        _decomposeRec(count, pos, melds + 1, hasPair, meldCount, result);
        count[pos]++;
        count[pos + 1]++;
        count[pos + 2]++;
      }
    }

    count[pos]--;
    _decomposeRec(count, pos + 1, melds, hasPair, meldCount, result);
    count[pos]++;
  }

  function _shantenChiitoiFromCount(count) {
    var pairs = 0;
    var kinds = 0;
    for (var i = 0; i < count.length; i++) {
      if (count[i] >= 1) kinds++;
      if (count[i] >= 2) pairs++;
    }
    if (kinds < 7) return 6 - pairs + (7 - kinds);
    return 6 - pairs;
  }

  function getListeningTiles(handTiles, pengTiles, gangTiles, ruleType) {
    var C = (typeof MahjongConstants !== 'undefined') ? MahjongConstants
          : (typeof require !== 'undefined') ? require('./mahjong-constants.js') : null;
    if (!C) return [];

    var meldCount = (pengTiles ? pengTiles.length : 0) + (gangTiles ? gangTiles.length : 0);
    var range = C.getRuleTileRange(ruleType);
    var count = C.tilesToCount(handTiles);
    var result = [];

    for (var i = range.min; i <= range.max; i++) {
      if (count[i] >= 4) continue;
      count[i]++;
      var shanten = calculateShantenFromCount(count, meldCount);
      if (shanten === -1) {
        var remaining = 4 - count[i] + 1;
        result.push({
          tileIndex: i,
          name: C.getTileShortName(i),
          remaining: remaining
        });
      }
      count[i]--;
    }
    return result;
  }

  function _getAcceptanceTiles(count, meldCount, range, C) {
    var tiles = [];
    var totalRemaining = 0;
    var currentShanten = calculateShantenFromCount(count, meldCount);

    for (var j = range.min; j <= range.max; j++) {
      if (count[j] >= 4) continue;
      count[j]++;
      var newShanten = calculateShantenFromCount(count, meldCount);
      if (newShanten < currentShanten) {
        var rem = 4 - count[j] + 1;
        tiles.push({
          tileIndex: j,
          name: C.getTileShortName(j),
          remaining: rem,
          isWin: (newShanten === -1)
        });
        totalRemaining += rem;
      }
      count[j]--;
    }
    return { tiles: tiles, totalRemaining: totalRemaining };
  }

  function getSuggestions(handTiles, pengTiles, gangTiles, ruleType, dingque) {
    var C = (typeof MahjongConstants !== 'undefined') ? MahjongConstants
          : (typeof require !== 'undefined') ? require('./mahjong-constants.js') : null;
    if (!C) return [];

    var meldCount = (pengTiles ? pengTiles.length : 0) + (gangTiles ? gangTiles.length : 0);
    var range = C.getRuleTileRange(ruleType);
    var count = C.tilesToCount(handTiles);
    var currentShanten = calculateShantenFromCount(count, meldCount);

    var dingqueRange = null;
    if (dingque === 'wan') dingqueRange = { start: 0, end: 8 };
    else if (dingque === 'tiao') dingqueRange = { start: 9, end: 17 };
    else if (dingque === 'tong') dingqueRange = { start: 18, end: 26 };

    var suggestions = [];

    for (var i = 0; i < TILE_COUNT; i++) {
      if (count[i] <= 0) continue;

      count[i]--;
      var newShanten = calculateShantenFromCount(count, meldCount);

      if (newShanten <= currentShanten) {
        var acceptance = _getAcceptanceTiles(count, meldCount, range, C);

        var listenTiles = [];
        var listenNames = [];
        var listenRemaining = 0;
        for (var k = 0; k < acceptance.tiles.length; k++) {
          if (acceptance.tiles[k].isWin) {
            listenTiles.push(acceptance.tiles[k]);
            listenNames.push(acceptance.tiles[k].name);
            listenRemaining += acceptance.tiles[k].remaining;
          }
        }

        var isDingque = false;
        if (dingqueRange && i >= dingqueRange.start && i <= dingqueRange.end) {
          isDingque = true;
        }

        suggestions.push({
          discardIndex: i,
          discardName: C.getTileShortName(i),
          shantenAfter: newShanten,
          acceptanceTiles: acceptance.tiles,
          acceptanceCount: acceptance.tiles.length,
          totalRemaining: acceptance.totalRemaining,
          listenTiles: listenTiles,
          listenCount: listenTiles.length,
          listenRemaining: listenRemaining,
          listenNames: listenNames.join(' '),
          isDingque: isDingque
        });
      }
      count[i]++;
    }

    suggestions.sort(function(a, b) {
      if (a.isDingque && !b.isDingque) return -1;
      if (!a.isDingque && b.isDingque) return 1;
      if (a.shantenAfter !== b.shantenAfter) return a.shantenAfter - b.shantenAfter;
      if (a.totalRemaining !== b.totalRemaining) return b.totalRemaining - a.totalRemaining;
      return b.acceptanceCount - a.acceptanceCount;
    });

    return suggestions;
  }

  function getAnalysis(handTiles, pengTiles, gangTiles, ruleType, dingque) {
    var C = (typeof MahjongConstants !== 'undefined') ? MahjongConstants
          : (typeof require !== 'undefined') ? require('./mahjong-constants.js') : null;
    if (!C) return null;

    var F = (typeof MahjongFan !== 'undefined') ? MahjongFan
          : (typeof require !== 'undefined') ? require('./mahjong-fan.js') : null;

    var meldCount = (pengTiles ? pengTiles.length : 0) + (gangTiles ? gangTiles.length : 0);
    var count = C.tilesToCount(handTiles);
    var currentShanten = calculateShantenFromCount(count, meldCount);

    var analysis = {
      handCount: handTiles.length,
      shanten: currentShanten,
      mode: 'error',
      shantenLabel: '',
      listenTiles: [],
      bestSuggestion: null,
      alternatives: [],
      suggestions: [],
      dingque: dingque || '',
      dingqueName: ''
    };

    if (dingque === 'wan') analysis.dingqueName = '万';
    else if (dingque === 'tiao') analysis.dingqueName = '条';
    else if (dingque === 'tong') analysis.dingqueName = '筒';

    var listenHandCount = 13 - meldCount * 2;
    var drawnHandCount = 14 - meldCount * 2;

    if (handTiles.length === listenHandCount) {
      if (currentShanten === -1) {
        analysis.mode = 'win';
      } else if (currentShanten === 0) {
        analysis.mode = 'listen';
        analysis.listenTiles = _getListenTilesFromCount(count, meldCount, ruleType, C, handTiles, pengTiles, gangTiles, dingque, F);
      } else {
        analysis.mode = 'shanten';
        analysis.shantenLabel = _shantenLabel(currentShanten);
        var range = C.getRuleTileRange(ruleType);
        var acceptance = _getAcceptanceTiles(count, meldCount, range, C);
        analysis.acceptanceTiles = acceptance.tiles;
        analysis.totalRemaining = acceptance.totalRemaining;
      }
    } else if (handTiles.length === drawnHandCount) {
      if (currentShanten === -1) {
        analysis.mode = 'win';
        if (F) {
          analysis.fanResult = F.calculateFan(handTiles, pengTiles, gangTiles, -1, ruleType, dingque, true, null);
        }
      } else {
        analysis.mode = 'suggest';
        var suggestions = getSuggestions(handTiles, pengTiles, gangTiles, ruleType, dingque);
        analysis.suggestions = suggestions;
        if (suggestions.length > 0) {
          analysis.bestSuggestion = suggestions[0];
          analysis.alternatives = suggestions.slice(1);
        }
      }
    } else {
      analysis.mode = 'error';
      analysis.errorDetail = '手牌' + handTiles.length + '张，期望' + listenHandCount + '张(听牌)或' + drawnHandCount + '张(打牌)';
    }

    return analysis;
  }

  function _getListenTilesFromCount(count, meldCount, ruleType, C, handTiles, pengTiles, gangTiles, dingque, F) {
    var range = C.getRuleTileRange(ruleType);
    var result = [];
    for (var i = range.min; i <= range.max; i++) {
      if (count[i] >= 4) continue;
      count[i]++;
      var shanten = calculateShantenFromCount(count, meldCount);
      if (shanten === -1) {
        var remaining = 4 - count[i] + 1;
        var fanResult = null;
        if (F) {
          fanResult = F.getFanForListen(handTiles, pengTiles, gangTiles, i, ruleType, dingque);
        }
        result.push({
          tileIndex: i,
          name: C.getTileShortName(i),
          remaining: remaining,
          fanResult: fanResult
        });
      }
      count[i]--;
    }
    return result;
  }

  function _shantenLabel(shanten) {
    if (shanten === 0) return '听牌';
    if (shanten === 1) return '一进听';
    if (shanten === 2) return '二进听';
    if (shanten === 3) return '三进听';
    return shanten + '进听';
  }

  return {
    calculateShanten: calculateShanten,
    calculateShantenFromCount: calculateShantenFromCount,
    getListeningTiles: getListeningTiles,
    getSuggestions: getSuggestions,
    getAnalysis: getAnalysis,
    _shantenLabel: _shantenLabel
  };
});
