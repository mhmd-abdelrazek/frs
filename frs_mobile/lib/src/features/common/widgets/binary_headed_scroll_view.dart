import 'package:flutter/material.dart';

/// A scroll view whose header snaps between [minHeight] and [maxHeight]
/// with an animated transition when the user lifts their finger.
///
/// [header] receives a `ratio` (1.0 = fully expanded, 0.0 = collapsed).
///
/// Layout order (top → bottom):
///   [header]       — snapping persistent header
///   [headerBottom] — optional widget below header, scrolls with content
///   [child]        — scrollable or plain box content
///   [footer]       — optional widget at the end of scroll content
///
/// [child] type is detected automatically:
///  - [CustomScrollView]      → slivers are merged directly
///  - [ListView]              → converted to SliverList
///    (covers .builder(), .separated(), .custom())
///  - [GridView]              → converted to SliverGrid
///    (covers .builder(), .count(), .extent(), .custom())
///  - [SingleChildScrollView] → inner child is unwrapped into SliverToBoxAdapter
///  - any other [ScrollView]  → nested in SliverFillRemaining (safe fallback)
///  - any other widget        → wrapped in SliverToBoxAdapter
class BinaryHeadedScrollView extends StatefulWidget {
  /// Builds the header. [ratio] is 1.0 when fully expanded, 0.0 when collapsed.
  final Widget header;

  /// Optional widget placed below the header and above [child].
  /// Scrolls away with the content (not pinned).
  final Widget? headerBottom;

  /// The scrollable (or plain box) content below the header.
  final Widget? child;

  /// Optional widget placed at the end of the scroll content.
  final Widget? footer;

  final ScrollController? controller;
  final double maxHeight;
  final double minHeight;
  final ScrollPhysics? physics;

  /// Duration of the binary snap animation.
  final Duration duration;

  /// Curve of the binary snap animation.
  final Curve curve;

  /// The scroll offset threshold that decides the snap direction.
  /// Defaults to the midpoint between [minHeight] and [maxHeight].
  /// Scrolling past this height snaps to collapsed; below it snaps to expanded.
  final double? thresholdHeight;

  const BinaryHeadedScrollView({
    required this.maxHeight,
    required this.minHeight,
    required this.header,
    this.headerBottom,
    this.child,
    this.footer,
    this.controller,
    this.thresholdHeight,
    super.key,
    this.physics,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  State<BinaryHeadedScrollView> createState() =>
      _BinaryHeadedScrollViewState();
}

class _BinaryHeadedScrollViewState
    extends State<BinaryHeadedScrollView> {
  late ScrollController _scrollController;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.controller == null) _scrollController.dispose();
    super.dispose();
  }

  void _onPointerUp(PointerUpEvent _) {
    if (!_scrollController.hasClients || _isAnimating) return;

    final shrinkRange = widget.maxHeight - widget.minHeight;
    if (shrinkRange <= 0) return;

    final offset = _scrollController.offset.clamp(0.0, shrinkRange);

    // Use thresholdHeight if provided, otherwise default to midpoint.
    final threshold = widget.thresholdHeight != null
        ? (widget.thresholdHeight! - widget.minHeight).clamp(0.0, shrinkRange)
        : shrinkRange / 2;

    final snapTo = offset >= threshold ? shrinkRange : 0.0;

    if ((offset - snapTo).abs() < 1.0) return;

    _isAnimating = true;
    _scrollController
        .animateTo(snapTo, duration: widget.duration, curve: widget.curve)
        .then((_) => _isAnimating = false);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Listener(
        onPointerUp: _onPointerUp,
        child: _buildScrollView(constraints),
      ),
    );
  }

  Widget _buildScrollView(BoxConstraints constraints) {
    final slivers = <Widget>[
      // ── Snapping header ────────────────────────────────────────────────────
      SliverPersistentHeader(
        pinned: true,
        delegate: _BinaryHeaderDelegate(
          header: widget.header,
          maxHeight: widget.maxHeight,
          minHeight: widget.minHeight,
        ),
      ),

      // ── Below-header widget (scrolls with content) ─────────────────────────
      if (widget.headerBottom != null)
        SliverToBoxAdapter(child: widget.headerBottom),

      // ── Main content ───────────────────────────────────────────────────────
      ..._buildContentSlivers(constraints),

      // ── Footer ────────────────────────────────────────────────────────────
      if (widget.footer != null) SliverToBoxAdapter(child: widget.footer),
    ];

    return CustomScrollView(
      controller: _scrollController,
      physics: widget.physics,
      slivers: slivers,
    );
  }

  List<Widget> _buildContentSlivers(BoxConstraints constraints) {
    final child = widget.child;
    if (child == null) return [];
    return _childToSlivers(child, constraints);
  }

  /// Converts [child] into one or more slivers depending on its runtime type.
  List<Widget> _childToSlivers(Widget child, BoxConstraints constraints) {
    if (child is CustomScrollView) {
      return [SliverList.list(children: child.slivers)];
    }

    if (child is ListView) {
      return [
        SliverPadding(
          padding: child.padding ?? EdgeInsets.zero,
          sliver: SliverList(delegate: child.childrenDelegate),
        ),
      ];
    }

    if (child is GridView) {
      return [
        SliverPadding(
          padding: child.padding ?? EdgeInsets.zero,
          sliver: SliverGrid(
            delegate: child.childrenDelegate,
            gridDelegate: child.gridDelegate,
          ),
        ),
      ];
    }

    if (child is SingleChildScrollView) {
      return [
        SliverPadding(
          padding: child.padding ?? EdgeInsets.zero,
          sliver: SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - widget.minHeight,
              ),
              child: child.child ?? const SizedBox(),
            ),
          ),
        ),
      ];
    }

    if (child is ScrollView) {
      return [SliverFillRemaining(child: child)];
    }

    // Plain box widget.
    return [
      SliverToBoxAdapter(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight - widget.minHeight,
          ),
          child: child,
        ),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Persistent header delegate
// ─────────────────────────────────────────────────────────────────────────────

class _BinaryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final Widget header;

  const _BinaryHeaderDelegate({
    required this.header,
    required this.maxHeight,
    required this.minHeight,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final height = (maxHeight - shrinkOffset).clamp(minHeight, maxHeight);
    return SizedBox(height: height, child: header);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
