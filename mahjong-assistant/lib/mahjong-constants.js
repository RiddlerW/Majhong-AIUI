(function(root, factory) {
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = factory();
  } else {
    root.MahjongConstants = factory();
  }
})(typeof self !== 'undefined' ? self : this, function() {

  var TILE_COUNT = 34;

  var TILE_NAMES = [
    '一万', '二万', '三万', '四万', '五万', '六万', '七万', '八万', '九万',
    '一条', '二条', '三条', '四条', '五条', '六条', '七条', '八条', '九条',
    '一筒', '二筒', '三筒', '四筒', '五筒', '六筒', '七筒', '八筒', '九筒',
    '东风', '南风', '西风', '北风',
    '红中', '发财', '白板'
  ];

  var TILE_SHORT_NAMES = [
    '1万', '2万', '3万', '4万', '5万', '6万', '7万', '8万', '9万',
    '1条', '2条', '3条', '4条', '5条', '6条', '7条', '8条', '9条',
    '1筒', '2筒', '3筒', '4筒', '5筒', '6筒', '7筒', '8筒', '9筒',
    '东', '南', '西', '北',
    '中', '发', '白'
  ];

  var TILE_DISPLAY_CHARS = [
    '🀇', '🀈', '🀉', '🀊', '🀋', '🀌', '🀍', '🀎', '🀏',
    '🀙', '🀚', '🀛', '🀜', '🀝', '🀞', '🀟', '🀠', '🀡',
    '🀐', '🀑', '🀒', '🀓', '🀔', '🀕', '🀖', '🀗', '🀘',
    '🀀', '🀁', '🀂', '🀃',
    '🀄', '🀅', '🀆'
  ];

  var SUIT_WAN = 0;
  var SUIT_TIAO = 1;
  var SUIT_TONG = 2;
  var SUIT_FENG = 3;
  var SUIT_JIAN = 4;

  var SUIT_RANGES = {
    wan:  { start: 0, end: 8 },
    tiao: { start: 9, end: 17 },
    tong: { start: 18, end: 26 },
    feng: { start: 27, end: 30 },
    jian: { start: 31, end: 33 }
  };

  var RULE_TYPES = {
    xz: {
      id: 'xz',
      name: '血战到底',
      description: '四川麻将，只有万条筒，可碰杠，胡牌后继续',
      tileRange: [0, 26],
      hasFengJian: false,
      hasHuaPai: false,
      minFan: 1
    },
    xl: {
      id: 'xl',
      name: '血流成河',
      description: '基于血战，胡牌后可继续摸打，一炮多响',
      tileRange: [0, 26],
      hasFengJian: false,
      hasHuaPai: false,
      minFan: 1
    },
    gb: {
      id: 'gb',
      name: '国标麻将',
      description: '144张牌含风箭，8番起胡，81种番型',
      tileRange: [0, 33],
      hasFengJian: true,
      hasHuaPai: false,
      minFan: 8
    }
  };

  var NAME_TO_INDEX = {};
  for (var i = 0; i < TILE_NAMES.length; i++) {
    NAME_TO_INDEX[TILE_NAMES[i]] = i;
  }
  for (var i = 0; i < TILE_SHORT_NAMES.length; i++) {
    NAME_TO_INDEX[TILE_SHORT_NAMES[i]] = i;
  }
  NAME_TO_INDEX['东'] = 27;
  NAME_TO_INDEX['南'] = 28;
  NAME_TO_INDEX['西'] = 29;
  NAME_TO_INDEX['北'] = 30;
  NAME_TO_INDEX['中'] = 31;
  NAME_TO_INDEX['发'] = 32;
  NAME_TO_INDEX['白'] = 33;
  NAME_TO_INDEX['红中'] = 31;
  NAME_TO_INDEX['发财'] = 32;
  NAME_TO_INDEX['白板'] = 33;

  function getTileName(index) {
    if (index >= 0 && index < TILE_NAMES.length) {
      return TILE_NAMES[index];
    }
    return '未知';
  }

  function getTileShortName(index) {
    if (index >= 0 && index < TILE_SHORT_NAMES.length) {
      return TILE_SHORT_NAMES[index];
    }
    return '?';
  }

  function getTileDisplayChar(index) {
    if (index >= 0 && index < TILE_DISPLAY_CHARS.length) {
      return TILE_DISPLAY_CHARS[index];
    }
    return '🀫';
  }

  function getSuitType(index) {
    if (index >= 0 && index <= 8) return SUIT_WAN;
    if (index >= 9 && index <= 17) return SUIT_TIAO;
    if (index >= 18 && index <= 26) return SUIT_TONG;
    if (index >= 27 && index <= 30) return SUIT_FENG;
    if (index >= 31 && index <= 33) return SUIT_JIAN;
    return -1;
  }

  function getSuitName(index) {
    var suit = getSuitType(index);
    switch (suit) {
      case SUIT_WAN: return '万';
      case SUIT_TIAO: return '条';
      case SUIT_TONG: return '筒';
      case SUIT_FENG: return '风';
      case SUIT_JIAN: return '箭';
      default: return '';
    }
  }

  function nameToIndex(name) {
    return NAME_TO_INDEX[name] !== undefined ? NAME_TO_INDEX[name] : -1;
  }

  function tilesToCount(tiles) {
    var count = new Array(TILE_COUNT).fill(0);
    for (var i = 0; i < tiles.length; i++) {
      var idx = tiles[i];
      if (idx >= 0 && idx < TILE_COUNT) {
        count[idx]++;
      }
    }
    return count;
  }

  function countToTiles(count) {
    var tiles = [];
    for (var i = 0; i < count.length; i++) {
      for (var j = 0; j < count[i]; j++) {
        tiles.push(i);
      }
    }
    return tiles;
  }

  function groupTilesBySuit(tiles) {
    var groups = {};
    for (var i = 0; i < tiles.length; i++) {
      var suit = getSuitName(tiles[i]);
      if (!groups[suit]) {
        groups[suit] = [];
      }
      groups[suit].push(tiles[i]);
    }
    for (var key in groups) {
      groups[key].sort(function(a, b) { return a - b; });
    }
    return groups;
  }

  function formatTilesForDisplay(tiles) {
    var groups = groupTilesBySuit(tiles);
    var parts = [];
    for (var suit in groups) {
      var names = groups[suit].map(function(t) { return getTileShortName(t); });
      parts.push(names.join(' '));
    }
    return parts.join('  ');
  }

  function formatTilesForPrompt(recognitionResult) {
    var handDesc = (recognitionResult.handTiles || []).map(function(t) {
      return getTileName(t);
    }).join('、');
    var pengDesc = (recognitionResult.pengTiles || []).map(function(group) {
      return group.map(function(t) { return getTileName(t); }).join('') + '(碰)';
    }).join('、');
    var gangDesc = (recognitionResult.gangTiles || []).map(function(group) {
      return group.map(function(t) { return getTileName(t); }).join('') + '(杠)';
    }).join('、');
    var result = '手牌: ' + handDesc;
    if (pengDesc) result += '；碰: ' + pengDesc;
    if (gangDesc) result += '；杠: ' + gangDesc;
    return result;
  }

  function getRuleTileRange(ruleType) {
    var rule = RULE_TYPES[ruleType];
    if (!rule) return { min: 0, max: TILE_COUNT - 1 };
    return { min: rule.tileRange[0], max: rule.tileRange[1] };
  }

  return {
    TILE_COUNT: TILE_COUNT,
    TILE_NAMES: TILE_NAMES,
    TILE_SHORT_NAMES: TILE_SHORT_NAMES,
    TILE_DISPLAY_CHARS: TILE_DISPLAY_CHARS,
    SUIT_WAN: SUIT_WAN,
    SUIT_TIAO: SUIT_TIAO,
    SUIT_TONG: SUIT_TONG,
    SUIT_FENG: SUIT_FENG,
    SUIT_JIAN: SUIT_JIAN,
    SUIT_RANGES: SUIT_RANGES,
    RULE_TYPES: RULE_TYPES,
    NAME_TO_INDEX: NAME_TO_INDEX,
    getTileName: getTileName,
    getTileShortName: getTileShortName,
    getTileDisplayChar: getTileDisplayChar,
    getSuitType: getSuitType,
    getSuitName: getSuitName,
    nameToIndex: nameToIndex,
    tilesToCount: tilesToCount,
    countToTiles: countToTiles,
    groupTilesBySuit: groupTilesBySuit,
    formatTilesForDisplay: formatTilesForDisplay,
    formatTilesForPrompt: formatTilesForPrompt,
    getRuleTileRange: getRuleTileRange
  };
});
