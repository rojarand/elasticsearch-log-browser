class Pair<K,V> {
  Pair(this.k, this.v);
  final K k;
  final V v;
  String toString() => '($k, $v)';
}

Iterable<Pair> asPairs(Map map) => map.keys.map((k) => new Pair(k, map[k]));

Map fromPairs(Iterable<Pair> pairs) => new Map.fromIterables(
    pairs.map((p) => p.k),
    pairs.map((p) => p.v));