import CLiveSplitCore

/// The analysis module provides a variety of functions for calculating
/// information about runs.
public class AnalysisRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// The analysis module provides a variety of functions for calculating
/// information about runs.
public class AnalysisRefMut: AnalysisRef {
}

/// The analysis module provides a variety of functions for calculating
/// information about runs.
public class Analysis : AnalysisRefMut {
    private func drop() {
        if self.ptr != nil {
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Calculates the Sum of Best Segments for the timing method provided. This is
    /// the fastest time possible to complete a run of a category, based on
    /// information collected from all the previous attempts. This often matches up
    /// with the sum of the best segment times of all the segments, but that may not
    /// always be the case, as skipped segments may introduce combined segments that
    /// may be faster than the actual sum of their best segment times. The name is
    /// therefore a bit misleading, but sticks around for historical reasons. You
    /// can choose to do a simple calculation instead, which excludes the Segment
    /// History from the calculation process. If there's an active attempt, you can
    /// choose to take it into account as well. Can return nil.
    public static func calculateSumOfBest(_ run: RunRef, _ simpleCalculation: Bool, _ useCurrentRun: Bool, _ method: UInt8) -> TimeSpan? {
        assert(run.ptr != nil)
        let result = CLiveSplitCore.Analysis_calculate_sum_of_best(run.ptr, simpleCalculation, useCurrentRun, method)
        if result == nil {
            return nil
        }
        return TimeSpan(ptr: result)
    }
    /// Calculates the total playtime of the passed Run.
    public static func calculateTotalPlaytimeForRun(_ run: RunRef) -> TimeSpan {
        assert(run.ptr != nil)
        let result = CLiveSplitCore.Analysis_calculate_total_playtime_for_run(run.ptr)
        return TimeSpan(ptr: result)
    }
    /// Calculates the total playtime of the passed Timer.
    public static func calculateTotalPlaytimeForTimer(_ timer: TimerRef) -> TimeSpan {
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.Analysis_calculate_total_playtime_for_timer(timer.ptr)
        return TimeSpan(ptr: result)
    }
}

/// An Atomic Date Time represents a UTC Date Time that tries to be as close to
/// an atomic clock as possible.
public class AtomicDateTimeRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Represents whether the date time is actually properly derived from an
    /// atomic clock. If the synchronization with the atomic clock didn't happen
    /// yet or failed, this is set to false.
    public func isSynchronized() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.AtomicDateTime_is_synchronized(self.ptr)
        return result
    }
    /// Converts this atomic date time into a RFC 2822 formatted date time.
    public func toRfc2822() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.AtomicDateTime_to_rfc2822(self.ptr)
        return String(cString: result!)
    }
    /// Converts this atomic date time into a RFC 3339 formatted date time.
    public func toRfc3339() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.AtomicDateTime_to_rfc3339(self.ptr)
        return String(cString: result!)
    }
}

/// An Atomic Date Time represents a UTC Date Time that tries to be as close to
/// an atomic clock as possible.
public class AtomicDateTimeRefMut: AtomicDateTimeRef {
}

/// An Atomic Date Time represents a UTC Date Time that tries to be as close to
/// an atomic clock as possible.
public class AtomicDateTime : AtomicDateTimeRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.AtomicDateTime_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// An Attempt describes information about an attempt to run a specific category
/// by a specific runner in the past. Every time a new attempt is started and
/// then reset, an Attempt describing general information about it is created.
public class AttemptRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Accesses the unique index of the attempt. This index is unique for the
    /// Run, not for all of them.
    public func index() -> Int32 {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Attempt_index(self.ptr)
        return result
    }
    /// Accesses the split time of the last segment. If the attempt got reset
    /// early and didn't finish, this may be empty.
    public func time() -> TimeRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Attempt_time(self.ptr)
        return TimeRef(ptr: result)
    }
    /// Accesses the amount of time the attempt has been paused for. If it is not
    /// known, this returns nil. This means that it may not necessarily be
    /// possible to differentiate whether a Run has not been paused or it simply
    /// wasn't stored.
    public func pauseTime() -> TimeSpanRef? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Attempt_pause_time(self.ptr)
        if result == nil {
            return nil
        }
        return TimeSpanRef(ptr: result)
    }
    /// Accesses the point in time the attempt was started at. This returns nil
    /// if this information is not known.
    public func started() -> AtomicDateTime? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Attempt_started(self.ptr)
        if result == nil {
            return nil
        }
        return AtomicDateTime(ptr: result)
    }
    /// Accesses the point in time the attempt was ended at. This returns nil if
    /// this information is not known.
    public func ended() -> AtomicDateTime? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Attempt_ended(self.ptr)
        if result == nil {
            return nil
        }
        return AtomicDateTime(ptr: result)
    }
}

/// An Attempt describes information about an attempt to run a specific category
/// by a specific runner in the past. Every time a new attempt is started and
/// then reset, an Attempt describing general information about it is created.
public class AttemptRefMut: AttemptRef {
}

/// An Attempt describes information about an attempt to run a specific category
/// by a specific runner in the past. Every time a new attempt is started and
/// then reset, an Attempt describing general information about it is created.
public class Attempt : AttemptRefMut {
    private func drop() {
        if self.ptr != nil {
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// With an Auto Splitting Runtime, the runner can use an Auto Splitter to
/// automatically control the timer on systems that are supported.
public class AutoSplittingRuntimeRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Attempts to load an auto splitter. Returns true if successful.
    public func loadScript(_ path: String) -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.AutoSplittingRuntime_load_script(self.ptr, path)
        return result
    }
    /// Attempts to unload the auto splitter. Returns true if successful.
    public func unloadScript() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.AutoSplittingRuntime_unload_script(self.ptr)
        return result
    }
}

/// With an Auto Splitting Runtime, the runner can use an Auto Splitter to
/// automatically control the timer on systems that are supported.
public class AutoSplittingRuntimeRefMut: AutoSplittingRuntimeRef {
}

/// With an Auto Splitting Runtime, the runner can use an Auto Splitter to
/// automatically control the timer on systems that are supported.
public class AutoSplittingRuntime : AutoSplittingRuntimeRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.AutoSplittingRuntime_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Auto Splitting Runtime for a Timer.
    public init(_ sharedTimer: SharedTimer) {
        assert(sharedTimer.ptr != nil)
        let result = CLiveSplitCore.AutoSplittingRuntime_new(sharedTimer.ptr)
        sharedTimer.ptr = nil
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/// The Blank Space Component is simply an empty component that doesn't show
/// anything other than a background. It mostly serves as padding between other
/// components.
public class BlankSpaceComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// The Blank Space Component is simply an empty component that doesn't show
/// anything other than a background. It mostly serves as padding between other
/// components.
public class BlankSpaceComponentRefMut: BlankSpaceComponentRef {
    /// Encodes the component's state information as JSON.
    public func stateAsJson() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.BlankSpaceComponent_state_as_json(self.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state.
    public func state() -> BlankSpaceComponentState {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.BlankSpaceComponent_state(self.ptr)
        return BlankSpaceComponentState(ptr: result)
    }
}

/// The Blank Space Component is simply an empty component that doesn't show
/// anything other than a background. It mostly serves as padding between other
/// components.
public class BlankSpaceComponent : BlankSpaceComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.BlankSpaceComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Blank Space Component.
    public init() {
        let result = CLiveSplitCore.BlankSpaceComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.BlankSpaceComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// The state object describes the information to visualize for this component.
public class BlankSpaceComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// The size of the component.
    public func size() -> UInt32 {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.BlankSpaceComponentState_size(self.ptr)
        return result
    }
}

/// The state object describes the information to visualize for this component.
public class BlankSpaceComponentStateRefMut: BlankSpaceComponentStateRef {
}

/// The state object describes the information to visualize for this component.
public class BlankSpaceComponentState : BlankSpaceComponentStateRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.BlankSpaceComponentState_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// A Component provides information about a run in a way that is easy to
/// visualize. This type can store any of the components provided by this crate.
public class ComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// A Component provides information about a run in a way that is easy to
/// visualize. This type can store any of the components provided by this crate.
public class ComponentRefMut: ComponentRef {
}

/// A Component provides information about a run in a way that is easy to
/// visualize. This type can store any of the components provided by this crate.
public class Component : ComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.Component_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// The Current Comparison Component is a component that shows the name of the
/// comparison that is currently selected to be compared against.
public class CurrentComparisonComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// The Current Comparison Component is a component that shows the name of the
/// comparison that is currently selected to be compared against.
public class CurrentComparisonComponentRefMut: CurrentComparisonComponentRef {
    /// Encodes the component's state information as JSON.
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.CurrentComparisonComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state based on the timer provided.
    public func state(_ timer: TimerRef) -> KeyValueComponentState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.CurrentComparisonComponent_state(self.ptr, timer.ptr)
        return KeyValueComponentState(ptr: result)
    }
}

/// The Current Comparison Component is a component that shows the name of the
/// comparison that is currently selected to be compared against.
public class CurrentComparisonComponent : CurrentComparisonComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.CurrentComparisonComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Current Comparison Component.
    public init() {
        let result = CLiveSplitCore.CurrentComparisonComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.CurrentComparisonComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// The Current Pace Component is a component that shows a prediction of the
/// current attempt's final time, if the current attempt's pace matches the
/// chosen comparison for the remainder of the run.
public class CurrentPaceComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// The Current Pace Component is a component that shows a prediction of the
/// current attempt's final time, if the current attempt's pace matches the
/// chosen comparison for the remainder of the run.
public class CurrentPaceComponentRefMut: CurrentPaceComponentRef {
    /// Encodes the component's state information as JSON.
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.CurrentPaceComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state based on the timer provided.
    public func state(_ timer: TimerRef) -> KeyValueComponentState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.CurrentPaceComponent_state(self.ptr, timer.ptr)
        return KeyValueComponentState(ptr: result)
    }
}

/// The Current Pace Component is a component that shows a prediction of the
/// current attempt's final time, if the current attempt's pace matches the
/// chosen comparison for the remainder of the run.
public class CurrentPaceComponent : CurrentPaceComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.CurrentPaceComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Current Pace Component.
    public init() {
        let result = CLiveSplitCore.CurrentPaceComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.CurrentPaceComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// The Delta Component is a component that shows the how far ahead or behind
/// the current attempt is compared to the chosen comparison.
public class DeltaComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// The Delta Component is a component that shows the how far ahead or behind
/// the current attempt is compared to the chosen comparison.
public class DeltaComponentRefMut: DeltaComponentRef {
    /// Encodes the component's state information as JSON.
    public func stateAsJson(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        assert(layoutSettings.ptr != nil)
        let result = CLiveSplitCore.DeltaComponent_state_as_json(self.ptr, timer.ptr, layoutSettings.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state based on the timer and the layout
    /// settings provided.
    public func state(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> KeyValueComponentState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        assert(layoutSettings.ptr != nil)
        let result = CLiveSplitCore.DeltaComponent_state(self.ptr, timer.ptr, layoutSettings.ptr)
        return KeyValueComponentState(ptr: result)
    }
}

/// The Delta Component is a component that shows the how far ahead or behind
/// the current attempt is compared to the chosen comparison.
public class DeltaComponent : DeltaComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.DeltaComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Delta Component.
    public init() {
        let result = CLiveSplitCore.DeltaComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DeltaComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// The Detailed Timer Component is a component that shows two timers, one for
/// the total time of the current attempt and one showing the time of just the
/// current segment. Other information, like segment times of up to two
/// comparisons, the segment icon, and the segment's name, can also be shown.
public class DetailedTimerComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// The Detailed Timer Component is a component that shows two timers, one for
/// the total time of the current attempt and one showing the time of just the
/// current segment. Other information, like segment times of up to two
/// comparisons, the segment icon, and the segment's name, can also be shown.
public class DetailedTimerComponentRefMut: DetailedTimerComponentRef {
    /// Encodes the component's state information as JSON.
    public func stateAsJson(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        assert(layoutSettings.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponent_state_as_json(self.ptr, timer.ptr, layoutSettings.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state based on the timer and layout settings
    /// provided.
    public func state(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> DetailedTimerComponentState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        assert(layoutSettings.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponent_state(self.ptr, timer.ptr, layoutSettings.ptr)
        return DetailedTimerComponentState(ptr: result)
    }
}

/// The Detailed Timer Component is a component that shows two timers, one for
/// the total time of the current attempt and one showing the time of just the
/// current segment. Other information, like segment times of up to two
/// comparisons, the segment icon, and the segment's name, can also be shown.
public class DetailedTimerComponent : DetailedTimerComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.DetailedTimerComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Detailed Timer Component.
    public init() {
        let result = CLiveSplitCore.DetailedTimerComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// The state object describes the information to visualize for this component.
public class DetailedTimerComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// The time shown by the component's main timer without the fractional part.
    public func timerTime() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponentState_timer_time(self.ptr)
        return String(cString: result!)
    }
    /// The fractional part of the time shown by the main timer (including the dot).
    public func timerFraction() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponentState_timer_fraction(self.ptr)
        return String(cString: result!)
    }
    /// The semantic coloring information the main timer's time carries.
    public func timerSemanticColor() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponentState_timer_semantic_color(self.ptr)
        return String(cString: result!)
    }
    /// The time shown by the component's segment timer without the fractional part.
    public func segmentTimerTime() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponentState_segment_timer_time(self.ptr)
        return String(cString: result!)
    }
    /// The fractional part of the time shown by the segment timer (including the
    /// dot).
    public func segmentTimerFraction() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponentState_segment_timer_fraction(self.ptr)
        return String(cString: result!)
    }
    /// Returns whether the first comparison is visible.
    public func comparison1Visible() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponentState_comparison1_visible(self.ptr)
        return result
    }
    /// Returns the name of the first comparison. You may not call this if the first
    /// comparison is not visible.
    public func comparison1Name() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponentState_comparison1_name(self.ptr)
        return String(cString: result!)
    }
    /// Returns the time of the first comparison. You may not call this if the first
    /// comparison is not visible.
    public func comparison1Time() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponentState_comparison1_time(self.ptr)
        return String(cString: result!)
    }
    /// Returns whether the second comparison is visible.
    public func comparison2Visible() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponentState_comparison2_visible(self.ptr)
        return result
    }
    /// Returns the name of the second comparison. You may not call this if the
    /// second comparison is not visible.
    public func comparison2Name() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponentState_comparison2_name(self.ptr)
        return String(cString: result!)
    }
    /// Returns the time of the second comparison. You may not call this if the
    /// second comparison is not visible.
    public func comparison2Time() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponentState_comparison2_time(self.ptr)
        return String(cString: result!)
    }
    /// The data of the segment's icon. This value is only specified whenever the
    /// icon changes. If you explicitly want to query this value, remount the
    /// component. The buffer itself may be empty. This indicates that there is no
    /// icon.
    public func iconChangePtr() -> UnsafeMutableRawPointer? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponentState_icon_change_ptr(self.ptr)
        return result
    }
    /// The length of the data of the segment's icon.
    public func iconChangeLen() -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponentState_icon_change_len(self.ptr)
        return result
    }
    /// The name of the segment. This may be nil if it's not supposed to be
    /// visualized.
    public func segmentName() -> String? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.DetailedTimerComponentState_segment_name(self.ptr)
        if let result = result {
            return String(cString: result)
        }
        return nil
    }
}

/// The state object describes the information to visualize for this component.
public class DetailedTimerComponentStateRefMut: DetailedTimerComponentStateRef {
}

/// The state object describes the information to visualize for this component.
public class DetailedTimerComponentState : DetailedTimerComponentStateRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.DetailedTimerComponentState_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// With a Fuzzy List, you can implement a fuzzy searching algorithm. The list
/// stores all the items that can be searched for. With the `search` method you
/// can then execute the actual fuzzy search which returns a list of all the
/// elements found. This can be used to implement searching in a list of games.
public class FuzzyListRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Searches for the pattern provided in the list. A list of all the
    /// matching elements is returned. The returned list has a maximum amount of
    /// elements provided to this method.
    public func search(_ pattern: String, _ max: size_t) -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.FuzzyList_search(self.ptr, pattern, max)
        return String(cString: result!)
    }
}

/// With a Fuzzy List, you can implement a fuzzy searching algorithm. The list
/// stores all the items that can be searched for. With the `search` method you
/// can then execute the actual fuzzy search which returns a list of all the
/// elements found. This can be used to implement searching in a list of games.
public class FuzzyListRefMut: FuzzyListRef {
    /// Adds a new element to the list.
    public func push(_ text: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.FuzzyList_push(self.ptr, text)
    }
}

/// With a Fuzzy List, you can implement a fuzzy searching algorithm. The list
/// stores all the items that can be searched for. With the `search` method you
/// can then execute the actual fuzzy search which returns a list of all the
/// elements found. This can be used to implement searching in a list of games.
public class FuzzyList : FuzzyListRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.FuzzyList_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Fuzzy List.
    public init() {
        let result = CLiveSplitCore.FuzzyList_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/// The general settings of the layout that apply to all components.
public class GeneralLayoutSettingsRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// The general settings of the layout that apply to all components.
public class GeneralLayoutSettingsRefMut: GeneralLayoutSettingsRef {
}

/// The general settings of the layout that apply to all components.
public class GeneralLayoutSettings : GeneralLayoutSettingsRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.GeneralLayoutSettings_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a default general layout settings configuration.
    public static func `default`() -> GeneralLayoutSettings {
        let result = CLiveSplitCore.GeneralLayoutSettings_default()
        return GeneralLayoutSettings(ptr: result)
    }
}

/// The Graph Component visualizes how far the current attempt has been ahead or
/// behind the chosen comparison throughout the whole attempt. All the
/// individual deltas are shown as points in a graph.
public class GraphComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Encodes the component's state information as JSON.
    public func stateAsJson(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        assert(layoutSettings.ptr != nil)
        let result = CLiveSplitCore.GraphComponent_state_as_json(self.ptr, timer.ptr, layoutSettings.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state based on the timer and layout settings
    /// provided.
    public func state(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> GraphComponentState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        assert(layoutSettings.ptr != nil)
        let result = CLiveSplitCore.GraphComponent_state(self.ptr, timer.ptr, layoutSettings.ptr)
        return GraphComponentState(ptr: result)
    }
}

/// The Graph Component visualizes how far the current attempt has been ahead or
/// behind the chosen comparison throughout the whole attempt. All the
/// individual deltas are shown as points in a graph.
public class GraphComponentRefMut: GraphComponentRef {
}

/// The Graph Component visualizes how far the current attempt has been ahead or
/// behind the chosen comparison throughout the whole attempt. All the
/// individual deltas are shown as points in a graph.
public class GraphComponent : GraphComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.GraphComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Graph Component.
    public init() {
        let result = CLiveSplitCore.GraphComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.GraphComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// The state object describes the information to visualize for this component.
/// All the coordinates are in the range 0..1.
public class GraphComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Returns the amount of points to visualize. Connect all of them to visualize
    /// the graph. If the live delta is active, the last point is to be interpreted
    /// as a preview of the next split that is about to happen. Use the partial fill
    /// color to visualize the region beneath that graph segment.
    public func pointsLen() -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.GraphComponentState_points_len(self.ptr)
        return result
    }
    /// Returns the x coordinate of the point specified. You may not provide an out
    /// of bounds index.
    public func pointX(_ index: size_t) -> Float {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.GraphComponentState_point_x(self.ptr, index)
        return result
    }
    /// Returns the y coordinate of the point specified. You may not provide an out
    /// of bounds index.
    public func pointY(_ index: size_t) -> Float {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.GraphComponentState_point_y(self.ptr, index)
        return result
    }
    /// Describes whether the segment the point specified is visualizing achieved a
    /// new best segment time. Use the best segment color for it, in that case. You
    /// may not provide an out of bounds index.
    public func pointIsBestSegment(_ index: size_t) -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.GraphComponentState_point_is_best_segment(self.ptr, index)
        return result
    }
    /// Describes how many horizontal grid lines to visualize.
    public func horizontalGridLinesLen() -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.GraphComponentState_horizontal_grid_lines_len(self.ptr)
        return result
    }
    /// Accesses the y coordinate of the horizontal grid line specified. You may not
    /// provide an out of bounds index.
    public func horizontalGridLine(_ index: size_t) -> Float {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.GraphComponentState_horizontal_grid_line(self.ptr, index)
        return result
    }
    /// Describes how many vertical grid lines to visualize.
    public func verticalGridLinesLen() -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.GraphComponentState_vertical_grid_lines_len(self.ptr)
        return result
    }
    /// Accesses the x coordinate of the vertical grid line specified. You may not
    /// provide an out of bounds index.
    public func verticalGridLine(_ index: size_t) -> Float {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.GraphComponentState_vertical_grid_line(self.ptr, index)
        return result
    }
    /// The y coordinate that separates the region that shows the times that are
    /// ahead of the comparison and those that are behind.
    public func middle() -> Float {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.GraphComponentState_middle(self.ptr)
        return result
    }
    /// If the live delta is active, the last point is to be interpreted as a
    /// preview of the next split that is about to happen. Use the partial fill
    /// color to visualize the region beneath that graph segment.
    public func isLiveDeltaActive() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.GraphComponentState_is_live_delta_active(self.ptr)
        return result
    }
    /// Describes whether the graph is flipped vertically. For visualizing the
    /// graph, this usually doesn't need to be interpreted, as this information is
    /// entirely encoded into the other variables.
    public func isFlipped() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.GraphComponentState_is_flipped(self.ptr)
        return result
    }
}

/// The state object describes the information to visualize for this component.
/// All the coordinates are in the range 0..1.
public class GraphComponentStateRefMut: GraphComponentStateRef {
}

/// The state object describes the information to visualize for this component.
/// All the coordinates are in the range 0..1.
public class GraphComponentState : GraphComponentStateRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.GraphComponentState_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// The configuration to use for a Hotkey System. It describes with keys to use
/// as hotkeys for the different actions.
public class HotkeyConfigRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Encodes generic description of the settings available for the hotkey
    /// configuration and their current values as JSON.
    public func settingsDescriptionAsJson() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.HotkeyConfig_settings_description_as_json(self.ptr)
        return String(cString: result!)
    }
    /// Encodes the hotkey configuration as JSON.
    public func asJson() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.HotkeyConfig_as_json(self.ptr)
        return String(cString: result!)
    }
}

/// The configuration to use for a Hotkey System. It describes with keys to use
/// as hotkeys for the different actions.
public class HotkeyConfigRefMut: HotkeyConfigRef {
    /// Sets a setting's value by its index to the given value.
    /// 
    /// false is returned if a hotkey is already in use by a different action.
    /// 
    /// This panics if the type of the value to be set is not compatible with the
    /// type of the setting's value. A panic can also occur if the index of the
    /// setting provided is out of bounds.
    public func setValue(_ index: size_t, _ value: SettingValue) -> Bool {
        assert(self.ptr != nil)
        assert(value.ptr != nil)
        let result = CLiveSplitCore.HotkeyConfig_set_value(self.ptr, index, value.ptr)
        value.ptr = nil
        return result
    }
}

/// The configuration to use for a Hotkey System. It describes with keys to use
/// as hotkeys for the different actions.
public class HotkeyConfig : HotkeyConfigRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.HotkeyConfig_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Hotkey Configuration with default settings.
    public init() {
        let result = CLiveSplitCore.HotkeyConfig_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Parses a hotkey configuration from the given JSON description. nil is
    /// returned if it couldn't be parsed.
    public static func parseJson(_ settings: String) -> HotkeyConfig? {
        let result = CLiveSplitCore.HotkeyConfig_parse_json(settings)
        if result == nil {
            return nil
        }
        return HotkeyConfig(ptr: result)
    }
    /// Attempts to parse a hotkey configuration from a given file. nil is
    /// returned it couldn't be parsed. This will not close the file descriptor /
    /// handle.
    public static func parseFileHandle(_ handle: Int64) -> HotkeyConfig? {
        let result = CLiveSplitCore.HotkeyConfig_parse_file_handle(handle)
        if result == nil {
            return nil
        }
        return HotkeyConfig(ptr: result)
    }
}

/// With a Hotkey System the runner can use hotkeys on their keyboard to control
/// the Timer. The hotkeys are global, so the application doesn't need to be in
/// focus. The behavior of the hotkeys depends on the platform and is stubbed
/// out on platforms that don't support hotkeys. You can turn off a Hotkey
/// System temporarily. By default the Hotkey System is activated.
public class HotkeySystemRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Returns the hotkey configuration currently in use by the Hotkey System.
    public func config() -> HotkeyConfig {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.HotkeySystem_config(self.ptr)
        return HotkeyConfig(ptr: result)
    }
}

/// With a Hotkey System the runner can use hotkeys on their keyboard to control
/// the Timer. The hotkeys are global, so the application doesn't need to be in
/// focus. The behavior of the hotkeys depends on the platform and is stubbed
/// out on platforms that don't support hotkeys. You can turn off a Hotkey
/// System temporarily. By default the Hotkey System is activated.
public class HotkeySystemRefMut: HotkeySystemRef {
    /// Deactivates the Hotkey System. No hotkeys will go through until it gets
    /// activated again. If it's already deactivated, nothing happens.
    public func deactivate() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.HotkeySystem_deactivate(self.ptr)
        return result
    }
    /// Activates a previously deactivated Hotkey System. If it's already
    /// active, nothing happens.
    public func activate() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.HotkeySystem_activate(self.ptr)
        return result
    }
    /// Applies a new hotkey configuration to the Hotkey System. Each hotkey is
    /// changed to the one specified in the configuration. This operation may fail
    /// if you provide a hotkey configuration where a hotkey is used for multiple
    /// operations. Returns false if the operation failed.
    public func setConfig(_ config: HotkeyConfig) -> Bool {
        assert(self.ptr != nil)
        assert(config.ptr != nil)
        let result = CLiveSplitCore.HotkeySystem_set_config(self.ptr, config.ptr)
        config.ptr = nil
        return result
    }
}

/// With a Hotkey System the runner can use hotkeys on their keyboard to control
/// the Timer. The hotkeys are global, so the application doesn't need to be in
/// focus. The behavior of the hotkeys depends on the platform and is stubbed
/// out on platforms that don't support hotkeys. You can turn off a Hotkey
/// System temporarily. By default the Hotkey System is activated.
public class HotkeySystem : HotkeySystemRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.HotkeySystem_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Hotkey System for a Timer with the default hotkeys.
    public init?(_ sharedTimer: SharedTimer) {
        assert(sharedTimer.ptr != nil)
        let result = CLiveSplitCore.HotkeySystem_new(sharedTimer.ptr)
        sharedTimer.ptr = nil
        if result == nil {
            return nil
        }
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Creates a new Hotkey System for a Timer with a custom configuration for the
    /// hotkeys.
    public static func withConfig(_ sharedTimer: SharedTimer, _ config: HotkeyConfig) -> HotkeySystem? {
        assert(sharedTimer.ptr != nil)
        assert(config.ptr != nil)
        let result = CLiveSplitCore.HotkeySystem_with_config(sharedTimer.ptr, config.ptr)
        sharedTimer.ptr = nil
        config.ptr = nil
        if result == nil {
            return nil
        }
        return HotkeySystem(ptr: result)
    }
}

/// The state object describes the information to visualize for a key value based component.
public class KeyValueComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// The key to visualize.
    public func key() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.KeyValueComponentState_key(self.ptr)
        return String(cString: result!)
    }
    /// The value to visualize.
    public func value() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.KeyValueComponentState_value(self.ptr)
        return String(cString: result!)
    }
    /// The semantic coloring information the value carries.
    public func semanticColor() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.KeyValueComponentState_semantic_color(self.ptr)
        return String(cString: result!)
    }
}

/// The state object describes the information to visualize for a key value based component.
public class KeyValueComponentStateRefMut: KeyValueComponentStateRef {
}

/// The state object describes the information to visualize for a key value based component.
public class KeyValueComponentState : KeyValueComponentStateRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.KeyValueComponentState_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// A Layout allows you to combine multiple components together to visualize a
/// variety of information the runner is interested in.
public class LayoutRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Clones the layout.
    public func clone() -> Layout {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Layout_clone(self.ptr)
        return Layout(ptr: result)
    }
    /// Encodes the settings of the layout as JSON.
    public func settingsAsJson() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Layout_settings_as_json(self.ptr)
        return String(cString: result!)
    }
}

/// A Layout allows you to combine multiple components together to visualize a
/// variety of information the runner is interested in.
public class LayoutRefMut: LayoutRef {
    /// Calculates and returns the layout's state based on the timer provided.
    public func state(_ timer: TimerRef) -> LayoutState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.Layout_state(self.ptr, timer.ptr)
        return LayoutState(ptr: result)
    }
    /// Updates the layout's state based on the timer provided.
    public func updateState(_ state: LayoutStateRefMut, _ timer: TimerRef) {
        assert(self.ptr != nil)
        assert(state.ptr != nil)
        assert(timer.ptr != nil)
        CLiveSplitCore.Layout_update_state(self.ptr, state.ptr, timer.ptr)
    }
    /// Updates the layout's state based on the timer provided and encodes it as
    /// JSON.
    public func updateStateAsJson(_ state: LayoutStateRefMut, _ timer: TimerRef) -> String {
        assert(self.ptr != nil)
        assert(state.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.Layout_update_state_as_json(self.ptr, state.ptr, timer.ptr)
        return String(cString: result!)
    }
    /// Calculates the layout's state based on the timer provided and encodes it as
    /// JSON. You can use this to visualize all of the components of a layout.
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.Layout_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /// Adds a new component to the end of the layout.
    public func push(_ component: Component) {
        assert(self.ptr != nil)
        assert(component.ptr != nil)
        CLiveSplitCore.Layout_push(self.ptr, component.ptr)
        component.ptr = nil
    }
    /// Scrolls up all the components in the layout that can be scrolled up.
    public func scrollUp() {
        assert(self.ptr != nil)
        CLiveSplitCore.Layout_scroll_up(self.ptr)
    }
    /// Scrolls down all the components in the layout that can be scrolled down.
    public func scrollDown() {
        assert(self.ptr != nil)
        CLiveSplitCore.Layout_scroll_down(self.ptr)
    }
    /// Remounts all the components as if they were freshly initialized. Some
    /// components may only provide some information whenever it changes or when
    /// their state is first queried. Remounting returns this information again,
    /// whenever the layout's state is queried the next time.
    public func remount() {
        assert(self.ptr != nil)
        CLiveSplitCore.Layout_remount(self.ptr)
    }
}

/// A Layout allows you to combine multiple components together to visualize a
/// variety of information the runner is interested in.
public class Layout : LayoutRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.Layout_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new empty layout with no components.
    public init() {
        let result = CLiveSplitCore.Layout_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Creates a new default layout that contains a default set of components
    /// in order to provide a good default layout for runners. Which components
    /// are provided by this and how they are configured may change in the
    /// future.
    public static func defaultLayout() -> Layout {
        let result = CLiveSplitCore.Layout_default_layout()
        return Layout(ptr: result)
    }
    /// Parses a layout from the given JSON description of its settings. nil is
    /// returned if it couldn't be parsed.
    public static func parseJson(_ settings: String) -> Layout? {
        let result = CLiveSplitCore.Layout_parse_json(settings)
        if result == nil {
            return nil
        }
        return Layout(ptr: result)
    }
    /// Attempts to parse a layout from a given file. nil is returned it couldn't
    /// be parsed. This will not close the file descriptor / handle.
    public static func parseFileHandle(_ handle: Int64) -> Layout? {
        let result = CLiveSplitCore.Layout_parse_file_handle(handle)
        if result == nil {
            return nil
        }
        return Layout(ptr: result)
    }
    /// Parses a layout saved by the original LiveSplit. This is lossy, as not
    /// everything can be converted completely. nil is returned if it couldn't be
    /// parsed at all.
    public static func parseOriginalLivesplit(_ data: UnsafeMutableRawPointer?, _ length: size_t) -> Layout? {
        let result = CLiveSplitCore.Layout_parse_original_livesplit(data, length)
        if result == nil {
            return nil
        }
        return Layout(ptr: result)
    }
}

/// The Layout Editor allows modifying Layouts while ensuring all the different
/// invariants of the Layout objects are upheld no matter what kind of
/// operations are being applied. It provides the current state of the editor as
/// state objects that can be visualized by any kind of User Interface.
public class LayoutEditorRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Encodes the Layout Editor's state as JSON in order to visualize it.
    public func stateAsJson() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutEditor_state_as_json(self.ptr)
        return String(cString: result!)
    }
    /// Returns the state of the Layout Editor.
    public func state() -> LayoutEditorState {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutEditor_state(self.ptr)
        return LayoutEditorState(ptr: result)
    }
}

/// The Layout Editor allows modifying Layouts while ensuring all the different
/// invariants of the Layout objects are upheld no matter what kind of
/// operations are being applied. It provides the current state of the editor as
/// state objects that can be visualized by any kind of User Interface.
public class LayoutEditorRefMut: LayoutEditorRef {
    /// Encodes the layout's state as JSON based on the timer provided. You can use
    /// this to visualize all of the components of a layout, while it is still being
    /// edited by the Layout Editor.
    public func layoutStateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.LayoutEditor_layout_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /// Updates the layout's state based on the timer provided.
    public func updateLayoutState(_ state: LayoutStateRefMut, _ timer: TimerRef) {
        assert(self.ptr != nil)
        assert(state.ptr != nil)
        assert(timer.ptr != nil)
        CLiveSplitCore.LayoutEditor_update_layout_state(self.ptr, state.ptr, timer.ptr)
    }
    /// Updates the layout's state based on the timer provided and encodes it as
    /// JSON.
    public func updateLayoutStateAsJson(_ state: LayoutStateRefMut, _ timer: TimerRef) -> String {
        assert(self.ptr != nil)
        assert(state.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.LayoutEditor_update_layout_state_as_json(self.ptr, state.ptr, timer.ptr)
        return String(cString: result!)
    }
    /// Selects the component with the given index in order to modify its
    /// settings. Only a single component is selected at any given time. You may
    /// not provide an invalid index.
    public func select(_ index: size_t) {
        assert(self.ptr != nil)
        CLiveSplitCore.LayoutEditor_select(self.ptr, index)
    }
    /// Adds the component provided to the end of the layout. The newly added
    /// component becomes the selected component.
    public func addComponent(_ component: Component) {
        assert(self.ptr != nil)
        assert(component.ptr != nil)
        CLiveSplitCore.LayoutEditor_add_component(self.ptr, component.ptr)
        component.ptr = nil
    }
    /// Removes the currently selected component, unless there's only one
    /// component in the layout. The next component becomes the selected
    /// component. If there's none, the previous component becomes the selected
    /// component instead.
    public func removeComponent() {
        assert(self.ptr != nil)
        CLiveSplitCore.LayoutEditor_remove_component(self.ptr)
    }
    /// Moves the selected component up, unless the first component is selected.
    public func moveComponentUp() {
        assert(self.ptr != nil)
        CLiveSplitCore.LayoutEditor_move_component_up(self.ptr)
    }
    /// Moves the selected component down, unless the last component is
    /// selected.
    public func moveComponentDown() {
        assert(self.ptr != nil)
        CLiveSplitCore.LayoutEditor_move_component_down(self.ptr)
    }
    /// Moves the selected component to the index provided. You may not provide
    /// an invalid index.
    public func moveComponent(_ dstIndex: size_t) {
        assert(self.ptr != nil)
        CLiveSplitCore.LayoutEditor_move_component(self.ptr, dstIndex)
    }
    /// Duplicates the currently selected component. The copy gets placed right
    /// after the selected component and becomes the newly selected component.
    public func duplicateComponent() {
        assert(self.ptr != nil)
        CLiveSplitCore.LayoutEditor_duplicate_component(self.ptr)
    }
    /// Sets a setting's value of the selected component by its setting index
    /// to the given value.
    /// 
    /// This panics if the type of the value to be set is not compatible with
    /// the type of the setting's value. A panic can also occur if the index of
    /// the setting provided is out of bounds.
    public func setComponentSettingsValue(_ index: size_t, _ value: SettingValue) {
        assert(self.ptr != nil)
        assert(value.ptr != nil)
        CLiveSplitCore.LayoutEditor_set_component_settings_value(self.ptr, index, value.ptr)
        value.ptr = nil
    }
    /// Sets a setting's value of the general settings by its setting index to
    /// the given value.
    /// 
    /// This panics if the type of the value to be set is not compatible with
    /// the type of the setting's value. A panic can also occur if the index of
    /// the setting provided is out of bounds.
    public func setGeneralSettingsValue(_ index: size_t, _ value: SettingValue) {
        assert(self.ptr != nil)
        assert(value.ptr != nil)
        CLiveSplitCore.LayoutEditor_set_general_settings_value(self.ptr, index, value.ptr)
        value.ptr = nil
    }
}

/// The Layout Editor allows modifying Layouts while ensuring all the different
/// invariants of the Layout objects are upheld no matter what kind of
/// operations are being applied. It provides the current state of the editor as
/// state objects that can be visualized by any kind of User Interface.
public class LayoutEditor : LayoutEditorRefMut {
    private func drop() {
        if self.ptr != nil {
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Layout Editor that modifies the Layout provided. Creation of
    /// the Layout Editor fails when a Layout with no components is provided. In
    /// that case nil is returned instead.
    public init?(_ layout: Layout) {
        assert(layout.ptr != nil)
        let result = CLiveSplitCore.LayoutEditor_new(layout.ptr)
        layout.ptr = nil
        if result == nil {
            return nil
        }
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Closes the Layout Editor and gives back access to the modified Layout. In
    /// case you want to implement a Cancel Button, just dispose the Layout object
    /// you get here.
    public func close() -> Layout {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutEditor_close(self.ptr)
        self.ptr = nil
        return Layout(ptr: result)
    }
}

/// Represents the current state of the Layout Editor in order to visualize it properly.
public class LayoutEditorStateRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Returns the number of components in the layout.
    public func componentLen() -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutEditorState_component_len(self.ptr)
        return result
    }
    /// Returns the name of the component at the specified index.
    public func componentText(_ index: size_t) -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutEditorState_component_text(self.ptr, index)
        return String(cString: result!)
    }
    /// Returns a bitfield corresponding to which buttons are active.
    /// 
    /// The bits are as follows:
    /// 
    /// * `0x04` - Can remove the current component
    /// * `0x02` - Can move the current component up
    /// * `0x01` - Can move the current component down
    public func buttons() -> UInt8 {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutEditorState_buttons(self.ptr)
        return result
    }
    /// Returns the index of the currently selected component.
    public func selectedComponent() -> UInt32 {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutEditorState_selected_component(self.ptr)
        return result
    }
    /// Returns the number of fields in the layout's settings.
    /// 
    /// Set `component_settings` to true to use the selected component's settings instead.
    public func fieldLen(_ componentSettings: Bool) -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutEditorState_field_len(self.ptr, componentSettings)
        return result
    }
    /// Returns the name of the layout's setting at the specified index.
    /// 
    /// Set `component_settings` to true to use the selected component's settings instead.
    public func fieldText(_ componentSettings: Bool, _ index: size_t) -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutEditorState_field_text(self.ptr, componentSettings, index)
        return String(cString: result!)
    }
    /// Returns the value of the layout's setting at the specified index.
    /// 
    /// Set `component_settings` to true to use the selected component's settings instead.
    public func fieldValue(_ componentSettings: Bool, _ index: size_t) -> SettingValueRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutEditorState_field_value(self.ptr, componentSettings, index)
        return SettingValueRef(ptr: result)
    }
}

/// Represents the current state of the Layout Editor in order to visualize it properly.
public class LayoutEditorStateRefMut: LayoutEditorStateRef {
}

/// Represents the current state of the Layout Editor in order to visualize it properly.
public class LayoutEditorState : LayoutEditorStateRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.LayoutEditorState_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// The state object describes the information to visualize for an entire
/// layout. Use this with care, as invalid usage will result in a panic.
/// 
/// Specifically, you should avoid doing the following:
/// 
/// - Using out of bounds indices.
/// - Using the wrong getter function on the wrong type of component.
public class LayoutStateRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Encodes the layout state as JSON. You can use this to visualize all of the
    /// components of a layout.
    public func asJson() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutState_as_json(self.ptr)
        return String(cString: result!)
    }
    /// Gets the number of Components in the Layout State.
    public func len() -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutState_len(self.ptr)
        return result
    }
    /// Returns a string describing the type of the Component at the specified
    /// index.
    public func componentType(_ index: size_t) -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutState_component_type(self.ptr, index)
        return String(cString: result!)
    }
    /// Gets the Blank Space component state at the specified index.
    public func componentAsBlankSpace(_ index: size_t) -> BlankSpaceComponentStateRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutState_component_as_blank_space(self.ptr, index)
        return BlankSpaceComponentStateRef(ptr: result)
    }
    /// Gets the Detailed Timer component state at the specified index.
    public func componentAsDetailedTimer(_ index: size_t) -> DetailedTimerComponentStateRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutState_component_as_detailed_timer(self.ptr, index)
        return DetailedTimerComponentStateRef(ptr: result)
    }
    /// Gets the Graph component state at the specified index.
    public func componentAsGraph(_ index: size_t) -> GraphComponentStateRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutState_component_as_graph(self.ptr, index)
        return GraphComponentStateRef(ptr: result)
    }
    /// Gets the Key Value component state at the specified index.
    public func componentAsKeyValue(_ index: size_t) -> KeyValueComponentStateRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutState_component_as_key_value(self.ptr, index)
        return KeyValueComponentStateRef(ptr: result)
    }
    /// Gets the Separator component state at the specified index.
    public func componentAsSeparator(_ index: size_t) -> SeparatorComponentStateRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutState_component_as_separator(self.ptr, index)
        return SeparatorComponentStateRef(ptr: result)
    }
    /// Gets the Splits component state at the specified index.
    public func componentAsSplits(_ index: size_t) -> SplitsComponentStateRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutState_component_as_splits(self.ptr, index)
        return SplitsComponentStateRef(ptr: result)
    }
    /// Gets the Text component state at the specified index.
    public func componentAsText(_ index: size_t) -> TextComponentStateRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutState_component_as_text(self.ptr, index)
        return TextComponentStateRef(ptr: result)
    }
    /// Gets the Timer component state at the specified index.
    public func componentAsTimer(_ index: size_t) -> TimerComponentStateRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutState_component_as_timer(self.ptr, index)
        return TimerComponentStateRef(ptr: result)
    }
    /// Gets the Title component state at the specified index.
    public func componentAsTitle(_ index: size_t) -> TitleComponentStateRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.LayoutState_component_as_title(self.ptr, index)
        return TitleComponentStateRef(ptr: result)
    }
}

/// The state object describes the information to visualize for an entire
/// layout. Use this with care, as invalid usage will result in a panic.
/// 
/// Specifically, you should avoid doing the following:
/// 
/// - Using out of bounds indices.
/// - Using the wrong getter function on the wrong type of component.
public class LayoutStateRefMut: LayoutStateRef {
}

/// The state object describes the information to visualize for an entire
/// layout. Use this with care, as invalid usage will result in a panic.
/// 
/// Specifically, you should avoid doing the following:
/// 
/// - Using out of bounds indices.
/// - Using the wrong getter function on the wrong type of component.
public class LayoutState : LayoutStateRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.LayoutState_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new empty Layout State. This is useful for creating an empty
    /// layout state that gets updated over time.
    public init() {
        let result = CLiveSplitCore.LayoutState_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/// A run parsed by the Composite Parser. This contains the Run itself and
/// information about which parser parsed it.
public class ParseRunResultRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Returns true if the Run got parsed successfully. false is returned otherwise.
    public func parsedSuccessfully() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.ParseRunResult_parsed_successfully(self.ptr)
        return result
    }
    /// Accesses the name of the Parser that parsed the Run. You may not call this
    /// if the Run wasn't parsed successfully.
    public func timerKind() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.ParseRunResult_timer_kind(self.ptr)
        return String(cString: result!)
    }
    /// Checks whether the Parser parsed a generic timer. Since a generic timer can
    /// have any name, it may clash with the specific timer formats that
    /// livesplit-core supports. With this function you can determine if a generic
    /// timer format was parsed, instead of one of the more specific timer formats.
    public func isGenericTimer() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.ParseRunResult_is_generic_timer(self.ptr)
        return result
    }
}

/// A run parsed by the Composite Parser. This contains the Run itself and
/// information about which parser parsed it.
public class ParseRunResultRefMut: ParseRunResultRef {
}

/// A run parsed by the Composite Parser. This contains the Run itself and
/// information about which parser parsed it.
public class ParseRunResult : ParseRunResultRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.ParseRunResult_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Moves the actual Run object out of the Result. You may not call this if the
    /// Run wasn't parsed successfully.
    public func unwrap() -> Run {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.ParseRunResult_unwrap(self.ptr)
        self.ptr = nil
        return Run(ptr: result)
    }
}

/// The PB Chance Component is a component that shows how likely it is to beat
/// the Personal Best. If there is no active attempt it shows the general chance
/// of beating the Personal Best. During an attempt it actively changes based on
/// how well the attempt is going.
public class PbChanceComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Encodes the component's state information as JSON.
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.PbChanceComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state based on the timer provided.
    public func state(_ timer: TimerRef) -> KeyValueComponentState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.PbChanceComponent_state(self.ptr, timer.ptr)
        return KeyValueComponentState(ptr: result)
    }
}

/// The PB Chance Component is a component that shows how likely it is to beat
/// the Personal Best. If there is no active attempt it shows the general chance
/// of beating the Personal Best. During an attempt it actively changes based on
/// how well the attempt is going.
public class PbChanceComponentRefMut: PbChanceComponentRef {
}

/// The PB Chance Component is a component that shows how likely it is to beat
/// the Personal Best. If there is no active attempt it shows the general chance
/// of beating the Personal Best. During an attempt it actively changes based on
/// how well the attempt is going.
public class PbChanceComponent : PbChanceComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.PbChanceComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new PB Chance Component.
    public init() {
        let result = CLiveSplitCore.PbChanceComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.PbChanceComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// The Possible Time Save Component is a component that shows how much time the
/// chosen comparison could've saved for the current segment, based on the Best
/// Segments. This component also allows showing the Total Possible Time Save
/// for the remainder of the current attempt.
public class PossibleTimeSaveComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Encodes the component's state information as JSON.
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.PossibleTimeSaveComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state based on the timer provided.
    public func state(_ timer: TimerRef) -> KeyValueComponentState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.PossibleTimeSaveComponent_state(self.ptr, timer.ptr)
        return KeyValueComponentState(ptr: result)
    }
}

/// The Possible Time Save Component is a component that shows how much time the
/// chosen comparison could've saved for the current segment, based on the Best
/// Segments. This component also allows showing the Total Possible Time Save
/// for the remainder of the current attempt.
public class PossibleTimeSaveComponentRefMut: PossibleTimeSaveComponentRef {
}

/// The Possible Time Save Component is a component that shows how much time the
/// chosen comparison could've saved for the current segment, based on the Best
/// Segments. This component also allows showing the Total Possible Time Save
/// for the remainder of the current attempt.
public class PossibleTimeSaveComponent : PossibleTimeSaveComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.PossibleTimeSaveComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Possible Time Save Component.
    public init() {
        let result = CLiveSplitCore.PossibleTimeSaveComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.PossibleTimeSaveComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// Describes a potential clean up that could be applied. You can query a
/// message describing the details of this potential clean up. A potential clean
/// up can then be turned into an actual clean up in order to apply it to the
/// Run.
public class PotentialCleanUpRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Accesses the message describing the potential clean up that can be applied
    /// to a Run.
    public func message() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.PotentialCleanUp_message(self.ptr)
        return String(cString: result!)
    }
}

/// Describes a potential clean up that could be applied. You can query a
/// message describing the details of this potential clean up. A potential clean
/// up can then be turned into an actual clean up in order to apply it to the
/// Run.
public class PotentialCleanUpRefMut: PotentialCleanUpRef {
}

/// Describes a potential clean up that could be applied. You can query a
/// message describing the details of this potential clean up. A potential clean
/// up can then be turned into an actual clean up in order to apply it to the
/// Run.
public class PotentialCleanUp : PotentialCleanUpRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.PotentialCleanUp_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// The Previous Segment Component is a component that shows how much time was
/// saved or lost during the previous segment based on the chosen comparison.
/// Additionally, the potential time save for the previous segment can be
/// displayed. This component switches to a `Live Segment` view that shows
/// active time loss whenever the runner is losing time on the current segment.
public class PreviousSegmentComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Encodes the component's state information as JSON.
    public func stateAsJson(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        assert(layoutSettings.ptr != nil)
        let result = CLiveSplitCore.PreviousSegmentComponent_state_as_json(self.ptr, timer.ptr, layoutSettings.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state based on the timer and the layout
    /// settings provided.
    public func state(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> KeyValueComponentState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        assert(layoutSettings.ptr != nil)
        let result = CLiveSplitCore.PreviousSegmentComponent_state(self.ptr, timer.ptr, layoutSettings.ptr)
        return KeyValueComponentState(ptr: result)
    }
}

/// The Previous Segment Component is a component that shows how much time was
/// saved or lost during the previous segment based on the chosen comparison.
/// Additionally, the potential time save for the previous segment can be
/// displayed. This component switches to a `Live Segment` view that shows
/// active time loss whenever the runner is losing time on the current segment.
public class PreviousSegmentComponentRefMut: PreviousSegmentComponentRef {
}

/// The Previous Segment Component is a component that shows how much time was
/// saved or lost during the previous segment based on the chosen comparison.
/// Additionally, the potential time save for the previous segment can be
/// displayed. This component switches to a `Live Segment` view that shows
/// active time loss whenever the runner is losing time on the current segment.
public class PreviousSegmentComponent : PreviousSegmentComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.PreviousSegmentComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Previous Segment Component.
    public init() {
        let result = CLiveSplitCore.PreviousSegmentComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.PreviousSegmentComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// A Run stores the split times for a specific game and category of a runner.
public class RunRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Clones the Run object.
    public func clone() -> Run {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_clone(self.ptr)
        return Run(ptr: result)
    }
    /// Accesses the name of the game this Run is for.
    public func gameName() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_game_name(self.ptr)
        return String(cString: result!)
    }
    /// Accesses the game icon's data. If there is no game icon, this returns an
    /// empty buffer.
    public func gameIconPtr() -> UnsafeMutableRawPointer? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_game_icon_ptr(self.ptr)
        return result
    }
    /// Accesses the amount of bytes the game icon's data takes up.
    public func gameIconLen() -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_game_icon_len(self.ptr)
        return result
    }
    /// Accesses the name of the category this Run is for.
    public func categoryName() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_category_name(self.ptr)
        return String(cString: result!)
    }
    /// Returns a file name (without the extension) suitable for this Run that
    /// is built the following way:
    /// 
    /// Game Name - Category Name
    /// 
    /// If either is empty, the dash is omitted. Special characters that cause
    /// problems in file names are also omitted. If an extended category name is
    /// used, the variables of the category are appended in a parenthesis.
    public func extendedFileName(_ useExtendedCategoryName: Bool) -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_extended_file_name(self.ptr, useExtendedCategoryName)
        return String(cString: result!)
    }
    /// Returns a name suitable for this Run that is built the following way:
    /// 
    /// Game Name - Category Name
    /// 
    /// If either is empty, the dash is omitted. If an extended category name is
    /// used, the variables of the category are appended in a parenthesis.
    public func extendedName(_ useExtendedCategoryName: Bool) -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_extended_name(self.ptr, useExtendedCategoryName)
        return String(cString: result!)
    }
    /// Returns an extended category name that possibly includes the region,
    /// platform and variables, depending on the arguments provided. An extended
    /// category name may look like this:
    /// 
    /// Any% (No Tuner, JPN, Wii Emulator)
    public func extendedCategoryName(_ showRegion: Bool, _ showPlatform: Bool, _ showVariables: Bool) -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_extended_category_name(self.ptr, showRegion, showPlatform, showVariables)
        return String(cString: result!)
    }
    /// Returns the amount of runs that have been attempted with these splits.
    public func attemptCount() -> UInt32 {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_attempt_count(self.ptr)
        return result
    }
    /// Accesses additional metadata of this Run, like the platform and region
    /// of the game.
    public func metadata() -> RunMetadataRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_metadata(self.ptr)
        return RunMetadataRef(ptr: result)
    }
    /// Accesses the time an attempt of this Run should start at.
    public func offset() -> TimeSpanRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_offset(self.ptr)
        return TimeSpanRef(ptr: result)
    }
    /// Returns the amount of segments stored in this Run.
    public func len() -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_len(self.ptr)
        return result
    }
    /// Returns whether the Run has been modified and should be saved so that the
    /// changes don't get lost.
    public func hasBeenModified() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_has_been_modified(self.ptr)
        return result
    }
    /// Accesses a certain segment of this Run. You may not provide an out of bounds
    /// index.
    public func segment(_ index: size_t) -> SegmentRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_segment(self.ptr, index)
        return SegmentRef(ptr: result)
    }
    /// Returns the amount attempt history elements are stored in this Run.
    public func attemptHistoryLen() -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_attempt_history_len(self.ptr)
        return result
    }
    /// Accesses the an attempt history element by its index. This does not store
    /// the actual segment times, just the overall attempt information. Information
    /// about the individual segments is stored within each segment. You may not
    /// provide an out of bounds index.
    public func attemptHistoryIndex(_ index: size_t) -> AttemptRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_attempt_history_index(self.ptr, index)
        return AttemptRef(ptr: result)
    }
    /// Saves a Run as a LiveSplit splits file (*.lss). If the run is actively in
    /// use by a timer, use the appropriate method on the timer instead, in order to
    /// properly save the current attempt as well.
    public func saveAsLss() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_save_as_lss(self.ptr)
        return String(cString: result!)
    }
    /// Returns the amount of custom comparisons stored in this Run.
    public func customComparisonsLen() -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_custom_comparisons_len(self.ptr)
        return result
    }
    /// Accesses a custom comparison stored in this Run by its index. This includes
    /// `Personal Best` but excludes all the other Comparison Generators. You may
    /// not provide an out of bounds index.
    public func customComparison(_ index: size_t) -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_custom_comparison(self.ptr, index)
        return String(cString: result!)
    }
    /// Accesses the Auto Splitter Settings that are encoded as XML.
    public func autoSplitterSettings() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Run_auto_splitter_settings(self.ptr)
        return String(cString: result!)
    }
}

/// A Run stores the split times for a specific game and category of a runner.
public class RunRefMut: RunRef {
    /// Pushes the segment provided to the end of the list of segments of this Run.
    public func pushSegment(_ segment: Segment) {
        assert(self.ptr != nil)
        assert(segment.ptr != nil)
        CLiveSplitCore.Run_push_segment(self.ptr, segment.ptr)
        segment.ptr = nil
    }
    /// Sets the name of the game this Run is for.
    public func setGameName(_ game: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.Run_set_game_name(self.ptr, game)
    }
    /// Sets the name of the category this Run is for.
    public func setCategoryName(_ category: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.Run_set_category_name(self.ptr, category)
    }
    /// Marks the Run as modified, so that it is known that there are changes
    /// that should be saved.
    public func markAsModified() {
        assert(self.ptr != nil)
        CLiveSplitCore.Run_mark_as_modified(self.ptr)
    }
}

/// A Run stores the split times for a specific game and category of a runner.
public class Run : RunRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.Run_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Run object with no segments.
    public init() {
        let result = CLiveSplitCore.Run_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Attempts to parse a splits file from an array by invoking the corresponding
    /// parser for the file format detected. A path to the splits file can be
    /// provided, which helps saving the splits file again later. Additionally you
    /// need to specify if additional files, like external images are allowed to be
    /// loaded. If you are using livesplit-core in a server-like environment, set
    /// this to false. Only client-side applications should set this to true.
    public static func parse(_ data: UnsafeMutableRawPointer?, _ length: size_t, _ path: String, _ loadFiles: Bool) -> ParseRunResult {
        let result = CLiveSplitCore.Run_parse(data, length, path, loadFiles)
        return ParseRunResult(ptr: result)
    }
    /// Attempts to parse a splits file from a file by invoking the corresponding
    /// parser for the file format detected. A path to the splits file can be
    /// provided, which helps saving the splits file again later. Additionally you
    /// need to specify if additional files, like external images are allowed to be
    /// loaded. If you are using livesplit-core in a server-like environment, set
    /// this to false. Only client-side applications should set this to true. On
    /// Unix you pass a file descriptor to this function. On Windows you pass a file
    /// handle to this function. The file descriptor / handle does not get closed.
    public static func parseFileHandle(_ handle: Int64, _ path: String, _ loadFiles: Bool) -> ParseRunResult {
        let result = CLiveSplitCore.Run_parse_file_handle(handle, path, loadFiles)
        return ParseRunResult(ptr: result)
    }
}

/// The Run Editor allows modifying Runs while ensuring that all the different
/// invariants of the Run objects are upheld no matter what kind of operations
/// are being applied to the Run. It provides the current state of the editor as
/// state objects that can be visualized by any kind of User Interface.
public class RunEditorRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// The Run Editor allows modifying Runs while ensuring that all the different
/// invariants of the Run objects are upheld no matter what kind of operations
/// are being applied to the Run. It provides the current state of the editor as
/// state objects that can be visualized by any kind of User Interface.
public class RunEditorRefMut: RunEditorRef {
    /// Calculates the Run Editor's state and encodes it as
    /// JSON in order to visualize it.
    public func stateAsJson() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunEditor_state_as_json(self.ptr)
        return String(cString: result!)
    }
    /// Selects a different timing method for being modified.
    public func selectTimingMethod(_ method: UInt8) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_select_timing_method(self.ptr, method)
    }
    /// Unselects the segment with the given index. If it's not selected or the
    /// index is out of bounds, nothing happens. The segment is not unselected,
    /// when it is the only segment that is selected. If the active segment is
    /// unselected, the most recently selected segment remaining becomes the
    /// active segment.
    public func unselect(_ index: size_t) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_unselect(self.ptr, index)
    }
    /// In addition to the segments that are already selected, the segment with
    /// the given index is being selected. The segment chosen also becomes the
    /// active segment.
    /// 
    /// This panics if the index of the segment provided is out of bounds.
    public func selectAdditionally(_ index: size_t) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_select_additionally(self.ptr, index)
    }
    /// Selects the segment with the given index. All other segments are
    /// unselected. The segment chosen also becomes the active segment.
    /// 
    /// This panics if the index of the segment provided is out of bounds.
    public func selectOnly(_ index: size_t) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_select_only(self.ptr, index)
    }
    /// Sets the name of the game.
    public func setGameName(_ game: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_set_game_name(self.ptr, game)
    }
    /// Sets the name of the category.
    public func setCategoryName(_ category: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_set_category_name(self.ptr, category)
    }
    /// Parses and sets the timer offset from the string provided. The timer
    /// offset specifies the time, the timer starts at when starting a new
    /// attempt.
    public func parseAndSetOffset(_ offset: String) -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunEditor_parse_and_set_offset(self.ptr, offset)
        return result
    }
    /// Parses and sets the attempt count from the string provided. Changing
    /// this has no affect on the attempt history or the segment history. This
    /// number is mostly just a visual number for the runner.
    public func parseAndSetAttemptCount(_ attempts: String) -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunEditor_parse_and_set_attempt_count(self.ptr, attempts)
        return result
    }
    /// Sets the game's icon.
    public func setGameIcon(_ data: UnsafeMutableRawPointer?, _ length: size_t) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_set_game_icon(self.ptr, data, length)
    }
    /// Removes the game's icon.
    public func removeGameIcon() {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_remove_game_icon(self.ptr)
    }
    /// Sets the speedrun.com Run ID of the run. You need to ensure that the
    /// record on speedrun.com matches up with the Personal Best of this run.
    /// This may be empty if there's no association.
    public func setRunId(_ name: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_set_run_id(self.ptr, name)
    }
    /// Sets the name of the region this game is from. This may be empty if it's
    /// not specified.
    public func setRegionName(_ name: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_set_region_name(self.ptr, name)
    }
    /// Sets the name of the platform this game is run on. This may be empty if
    /// it's not specified.
    public func setPlatformName(_ name: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_set_platform_name(self.ptr, name)
    }
    /// Specifies whether this speedrun is done on an emulator. Keep in mind
    /// that false may also mean that this information is simply not known.
    public func setEmulatorUsage(_ usesEmulator: Bool) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_set_emulator_usage(self.ptr, usesEmulator)
    }
    /// Sets the speedrun.com variable with the name specified to the value specified. A
    /// variable is an arbitrary key value pair storing additional information
    /// about the category. An example of this may be whether Amiibos are used
    /// in this category. If the variable doesn't exist yet, it is being
    /// inserted.
    public func setSpeedrunComVariable(_ name: String, _ value: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_set_speedrun_com_variable(self.ptr, name, value)
    }
    /// Removes the speedrun.com variable with the name specified.
    public func removeSpeedrunComVariable(_ name: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_remove_speedrun_com_variable(self.ptr, name)
    }
    /// Adds a new permanent custom variable. If there's a temporary variable with
    /// the same name, it gets turned into a permanent variable and its value stays.
    /// If a permanent variable with the name already exists, nothing happens.
    public func addCustomVariable(_ name: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_add_custom_variable(self.ptr, name)
    }
    /// Sets the value of a custom variable with the name specified. If the custom
    /// variable does not exist, or is not a permanent variable, nothing happens.
    public func setCustomVariable(_ name: String, _ value: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_set_custom_variable(self.ptr, name, value)
    }
    /// Removes the custom variable with the name specified. If the custom variable
    /// does not exist, or is not a permanent variable, nothing happens.
    public func removeCustomVariable(_ name: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_remove_custom_variable(self.ptr, name)
    }
    /// Resets all the Metadata Information.
    public func clearMetadata() {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_clear_metadata(self.ptr)
    }
    /// Inserts a new empty segment above the active segment and adjusts the
    /// Run's history information accordingly. The newly created segment is then
    /// the only selected segment and also the active segment.
    public func insertSegmentAbove() {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_insert_segment_above(self.ptr)
    }
    /// Inserts a new empty segment below the active segment and adjusts the
    /// Run's history information accordingly. The newly created segment is then
    /// the only selected segment and also the active segment.
    public func insertSegmentBelow() {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_insert_segment_below(self.ptr)
    }
    /// Removes all the selected segments, unless all of them are selected. The
    /// run's information is automatically adjusted properly. The next
    /// not-to-be-removed segment after the active segment becomes the new
    /// active segment. If there's none, then the next not-to-be-removed segment
    /// before the active segment, becomes the new active segment.
    public func removeSegments() {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_remove_segments(self.ptr)
    }
    /// Moves all the selected segments up, unless the first segment is
    /// selected. The run's information is automatically adjusted properly. The
    /// active segment stays the active segment.
    public func moveSegmentsUp() {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_move_segments_up(self.ptr)
    }
    /// Moves all the selected segments down, unless the last segment is
    /// selected. The run's information is automatically adjusted properly. The
    /// active segment stays the active segment.
    public func moveSegmentsDown() {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_move_segments_down(self.ptr)
    }
    /// Sets the icon of the active segment.
    public func activeSetIcon(_ data: UnsafeMutableRawPointer?, _ length: size_t) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_active_set_icon(self.ptr, data, length)
    }
    /// Removes the icon of the active segment.
    public func activeRemoveIcon() {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_active_remove_icon(self.ptr)
    }
    /// Sets the name of the active segment.
    public func activeSetName(_ name: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_active_set_name(self.ptr, name)
    }
    /// Parses a split time from a string and sets it for the active segment with
    /// the chosen timing method.
    public func activeParseAndSetSplitTime(_ time: String) -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunEditor_active_parse_and_set_split_time(self.ptr, time)
        return result
    }
    /// Parses a segment time from a string and sets it for the active segment with
    /// the chosen timing method.
    public func activeParseAndSetSegmentTime(_ time: String) -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunEditor_active_parse_and_set_segment_time(self.ptr, time)
        return result
    }
    /// Parses a best segment time from a string and sets it for the active segment
    /// with the chosen timing method.
    public func activeParseAndSetBestSegmentTime(_ time: String) -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunEditor_active_parse_and_set_best_segment_time(self.ptr, time)
        return result
    }
    /// Parses a comparison time for the provided comparison and sets it for the
    /// active active segment with the chosen timing method.
    public func activeParseAndSetComparisonTime(_ comparison: String, _ time: String) -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunEditor_active_parse_and_set_comparison_time(self.ptr, comparison, time)
        return result
    }
    /// Adds a new custom comparison. It can't be added if it starts with
    /// `[Race]` or already exists.
    public func addComparison(_ comparison: String) -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunEditor_add_comparison(self.ptr, comparison)
        return result
    }
    /// Imports the Personal Best from the provided run as a comparison. The
    /// comparison can't be added if its name starts with `[Race]` or it already
    /// exists.
    public func importComparison(_ run: RunRef, _ comparison: String) -> Bool {
        assert(self.ptr != nil)
        assert(run.ptr != nil)
        let result = CLiveSplitCore.RunEditor_import_comparison(self.ptr, run.ptr, comparison)
        return result
    }
    /// Removes the chosen custom comparison. You can't remove a Comparison
    /// Generator's Comparison or the Personal Best.
    public func removeComparison(_ comparison: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_remove_comparison(self.ptr, comparison)
    }
    /// Renames a comparison. The comparison can't be renamed if the new name of
    /// the comparison starts with `[Race]` or it already exists.
    public func renameComparison(_ oldName: String, _ newName: String) -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunEditor_rename_comparison(self.ptr, oldName, newName)
        return result
    }
    /// Reorders the custom comparisons by moving the comparison with the source
    /// index specified to the destination index specified. Returns false if one
    /// of the indices is invalid. The indices are based on the comparison names of
    /// the Run Editor's state.
    public func moveComparison(_ srcIndex: size_t, _ dstIndex: size_t) -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunEditor_move_comparison(self.ptr, srcIndex, dstIndex)
        return result
    }
    /// Parses a goal time and generates a custom goal comparison based on the
    /// parsed value. The comparison's times are automatically balanced based on the
    /// runner's history such that it roughly represents what split times for the
    /// goal time would roughly look like. Since it is populated by the runner's
    /// history, only goal times within the sum of the best segments and the sum of
    /// the worst segments are supported. Everything else is automatically capped by
    /// that range. The comparison is only populated for the selected timing method.
    /// The other timing method's comparison times are not modified by this, so you
    /// can call this again with the other timing method to generate the comparison
    /// times for both timing methods.
    public func parseAndGenerateGoalComparison(_ time: String) -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunEditor_parse_and_generate_goal_comparison(self.ptr, time)
        return result
    }
    /// Clears out the Attempt History and the Segment Histories of all the
    /// segments.
    public func clearHistory() {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_clear_history(self.ptr)
    }
    /// Clears out the Attempt History, the Segment Histories, all the times,
    /// sets the Attempt Count to 0 and clears the speedrun.com run id
    /// association. All Custom Comparisons other than `Personal Best` are
    /// deleted as well.
    public func clearTimes() {
        assert(self.ptr != nil)
        CLiveSplitCore.RunEditor_clear_times(self.ptr)
    }
    /// Creates a Sum of Best Cleaner which allows you to interactively remove
    /// potential issues in the segment history that lead to an inaccurate Sum
    /// of Best. If you skip a split, whenever you will do the next split, the
    /// combined segment time might be faster than the sum of the individual
    /// best segments. The Sum of Best Cleaner will point out all of these and
    /// allows you to delete them individually if any of them seem wrong.
    public func cleanSumOfBest() -> SumOfBestCleaner {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunEditor_clean_sum_of_best(self.ptr)
        return SumOfBestCleaner(ptr: result)
    }
}

/// The Run Editor allows modifying Runs while ensuring that all the different
/// invariants of the Run objects are upheld no matter what kind of operations
/// are being applied to the Run. It provides the current state of the editor as
/// state objects that can be visualized by any kind of User Interface.
public class RunEditor : RunEditorRefMut {
    private func drop() {
        if self.ptr != nil {
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Run Editor that modifies the Run provided. Creation of the Run
    /// Editor fails when a Run with no segments is provided. If a Run object with
    /// no segments is provided, the Run Editor creation fails and nil is
    /// returned.
    public init?(_ run: Run) {
        assert(run.ptr != nil)
        let result = CLiveSplitCore.RunEditor_new(run.ptr)
        run.ptr = nil
        if result == nil {
            return nil
        }
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Closes the Run Editor and gives back access to the modified Run object. In
    /// case you want to implement a Cancel Button, just dispose the Run object you
    /// get here.
    public func close() -> Run {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunEditor_close(self.ptr)
        self.ptr = nil
        return Run(ptr: result)
    }
}

/// The Run Metadata stores additional information about a run, like the
/// platform and region of the game. All of this information is optional.
public class RunMetadataRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Accesses the speedrun.com Run ID of the run. This Run ID specify which
    /// Record on speedrun.com this run is associated with. This should be
    /// changed once the Personal Best doesn't match up with that record
    /// anymore. This may be empty if there's no association.
    public func runId() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunMetadata_run_id(self.ptr)
        return String(cString: result!)
    }
    /// Accesses the name of the platform this game is run on. This may be empty
    /// if it's not specified.
    public func platformName() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunMetadata_platform_name(self.ptr)
        return String(cString: result!)
    }
    /// Returns true if this speedrun is done on an emulator. However false
    /// may also indicate that this information is simply not known.
    public func usesEmulator() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunMetadata_uses_emulator(self.ptr)
        return result
    }
    /// Accesses the name of the region this game is from. This may be empty if
    /// it's not specified.
    public func regionName() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunMetadata_region_name(self.ptr)
        return String(cString: result!)
    }
    /// Returns an iterator iterating over all the speedrun.com variables and their
    /// values that have been specified.
    public func speedrunComVariables() -> RunMetadataSpeedrunComVariablesIter {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunMetadata_speedrun_com_variables(self.ptr)
        return RunMetadataSpeedrunComVariablesIter(ptr: result)
    }
    /// Returns an iterator iterating over all the custom variables and their
    /// values. This includes both temporary and permanent variables.
    public func customVariables() -> RunMetadataCustomVariablesIter {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunMetadata_custom_variables(self.ptr)
        return RunMetadataCustomVariablesIter(ptr: result)
    }
}

/// The Run Metadata stores additional information about a run, like the
/// platform and region of the game. All of this information is optional.
public class RunMetadataRefMut: RunMetadataRef {
}

/// The Run Metadata stores additional information about a run, like the
/// platform and region of the game. All of this information is optional.
public class RunMetadata : RunMetadataRefMut {
    private func drop() {
        if self.ptr != nil {
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// A custom variable is a key value pair storing additional information about a
/// run. Unlike the speedrun.com variables, these can be fully custom and don't
/// need to correspond to anything on speedrun.com. Permanent custom variables
/// can be specified by the runner. Additionally auto splitters or other sources
/// may provide temporary custom variables that are not stored in the splits
/// files.
public class RunMetadataCustomVariableRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Accesses the name of this custom variable.
    public func name() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunMetadataCustomVariable_name(self.ptr)
        return String(cString: result!)
    }
    /// Accesses the value of this custom variable.
    public func value() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunMetadataCustomVariable_value(self.ptr)
        return String(cString: result!)
    }
    /// Returns true if the custom variable is permanent. Permanent variables get
    /// stored in the splits file and are visible in the run editor. Temporary
    /// variables are not.
    public func isPermanent() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunMetadataCustomVariable_is_permanent(self.ptr)
        return result
    }
}

/// A custom variable is a key value pair storing additional information about a
/// run. Unlike the speedrun.com variables, these can be fully custom and don't
/// need to correspond to anything on speedrun.com. Permanent custom variables
/// can be specified by the runner. Additionally auto splitters or other sources
/// may provide temporary custom variables that are not stored in the splits
/// files.
public class RunMetadataCustomVariableRefMut: RunMetadataCustomVariableRef {
}

/// A custom variable is a key value pair storing additional information about a
/// run. Unlike the speedrun.com variables, these can be fully custom and don't
/// need to correspond to anything on speedrun.com. Permanent custom variables
/// can be specified by the runner. Additionally auto splitters or other sources
/// may provide temporary custom variables that are not stored in the splits
/// files.
public class RunMetadataCustomVariable : RunMetadataCustomVariableRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.RunMetadataCustomVariable_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// An iterator iterating over all the custom variables and their values
/// that have been specified.
public class RunMetadataCustomVariablesIterRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// An iterator iterating over all the custom variables and their values
/// that have been specified.
public class RunMetadataCustomVariablesIterRefMut: RunMetadataCustomVariablesIterRef {
    /// Accesses the next custom variable. Returns nil if there are no more
    /// variables.
    public func next() -> RunMetadataCustomVariableRef? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunMetadataCustomVariablesIter_next(self.ptr)
        if result == nil {
            return nil
        }
        return RunMetadataCustomVariableRef(ptr: result)
    }
}

/// An iterator iterating over all the custom variables and their values
/// that have been specified.
public class RunMetadataCustomVariablesIter : RunMetadataCustomVariablesIterRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.RunMetadataCustomVariablesIter_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// A speedrun.com variable is an arbitrary key value pair storing additional
/// information about the category. An example of this may be whether Amiibos
/// are used in the category.
public class RunMetadataSpeedrunComVariableRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Accesses the name of this speedrun.com variable.
    public func name() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunMetadataSpeedrunComVariable_name(self.ptr)
        return String(cString: result!)
    }
    /// Accesses the value of this speedrun.com variable.
    public func value() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunMetadataSpeedrunComVariable_value(self.ptr)
        return String(cString: result!)
    }
}

/// A speedrun.com variable is an arbitrary key value pair storing additional
/// information about the category. An example of this may be whether Amiibos
/// are used in the category.
public class RunMetadataSpeedrunComVariableRefMut: RunMetadataSpeedrunComVariableRef {
}

/// A speedrun.com variable is an arbitrary key value pair storing additional
/// information about the category. An example of this may be whether Amiibos
/// are used in the category.
public class RunMetadataSpeedrunComVariable : RunMetadataSpeedrunComVariableRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.RunMetadataSpeedrunComVariable_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// An iterator iterating over all the speedrun.com variables and their values
/// that have been specified.
public class RunMetadataSpeedrunComVariablesIterRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// An iterator iterating over all the speedrun.com variables and their values
/// that have been specified.
public class RunMetadataSpeedrunComVariablesIterRefMut: RunMetadataSpeedrunComVariablesIterRef {
    /// Accesses the next speedrun.com variable. Returns nil if there are no more
    /// variables.
    public func next() -> RunMetadataSpeedrunComVariableRef? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.RunMetadataSpeedrunComVariablesIter_next(self.ptr)
        if result == nil {
            return nil
        }
        return RunMetadataSpeedrunComVariableRef(ptr: result)
    }
}

/// An iterator iterating over all the speedrun.com variables and their values
/// that have been specified.
public class RunMetadataSpeedrunComVariablesIter : RunMetadataSpeedrunComVariablesIterRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.RunMetadataSpeedrunComVariablesIter_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// A Segment describes a point in a speedrun that is suitable for storing a
/// split time. This stores the name of that segment, an icon, the split times
/// of different comparisons, and a history of segment times.
public class SegmentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Accesses the name of the segment.
    public func name() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Segment_name(self.ptr)
        return String(cString: result!)
    }
    /// Accesses the segment icon's data. If there is no segment icon, this returns
    /// an empty buffer.
    public func iconPtr() -> UnsafeMutableRawPointer? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Segment_icon_ptr(self.ptr)
        return result
    }
    /// Accesses the amount of bytes the segment icon's data takes up.
    public func iconLen() -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Segment_icon_len(self.ptr)
        return result
    }
    /// Accesses the specified comparison's time. If there's none for this
    /// comparison, an empty time is being returned (but not stored in the
    /// segment).
    public func comparison(_ comparison: String) -> TimeRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Segment_comparison(self.ptr, comparison)
        return TimeRef(ptr: result)
    }
    /// Accesses the split time of the Personal Best for this segment. If it
    /// doesn't exist, an empty time is returned.
    public func personalBestSplitTime() -> TimeRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Segment_personal_best_split_time(self.ptr)
        return TimeRef(ptr: result)
    }
    /// Accesses the Best Segment Time.
    public func bestSegmentTime() -> TimeRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Segment_best_segment_time(self.ptr)
        return TimeRef(ptr: result)
    }
    /// Accesses the Segment History of this segment.
    public func segmentHistory() -> SegmentHistoryRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Segment_segment_history(self.ptr)
        return SegmentHistoryRef(ptr: result)
    }
}

/// A Segment describes a point in a speedrun that is suitable for storing a
/// split time. This stores the name of that segment, an icon, the split times
/// of different comparisons, and a history of segment times.
public class SegmentRefMut: SegmentRef {
}

/// A Segment describes a point in a speedrun that is suitable for storing a
/// split time. This stores the name of that segment, an icon, the split times
/// of different comparisons, and a history of segment times.
public class Segment : SegmentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.Segment_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Segment with the name given.
    public init(_ name: String) {
        let result = CLiveSplitCore.Segment_new(name)
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/// Stores the segment times achieved for a certain segment. Each segment is
/// tagged with an index. Only segment times with an index larger than 0 are
/// considered times actually achieved by the runner, while the others are
/// artifacts of route changes and similar algorithmic changes.
public class SegmentHistoryRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Iterates over all the segment times and their indices.
    public func iter() -> SegmentHistoryIter {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SegmentHistory_iter(self.ptr)
        return SegmentHistoryIter(ptr: result)
    }
}

/// Stores the segment times achieved for a certain segment. Each segment is
/// tagged with an index. Only segment times with an index larger than 0 are
/// considered times actually achieved by the runner, while the others are
/// artifacts of route changes and similar algorithmic changes.
public class SegmentHistoryRefMut: SegmentHistoryRef {
}

/// Stores the segment times achieved for a certain segment. Each segment is
/// tagged with an index. Only segment times with an index larger than 0 are
/// considered times actually achieved by the runner, while the others are
/// artifacts of route changes and similar algorithmic changes.
public class SegmentHistory : SegmentHistoryRefMut {
    private func drop() {
        if self.ptr != nil {
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// A segment time achieved for a segment. It is tagged with an index. Only
/// segment times with an index larger than 0 are considered times actually
/// achieved by the runner, while the others are artifacts of route changes and
/// similar algorithmic changes.
public class SegmentHistoryElementRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Accesses the index of the segment history element.
    public func index() -> Int32 {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SegmentHistoryElement_index(self.ptr)
        return result
    }
    /// Accesses the segment time of the segment history element.
    public func time() -> TimeRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SegmentHistoryElement_time(self.ptr)
        return TimeRef(ptr: result)
    }
}

/// A segment time achieved for a segment. It is tagged with an index. Only
/// segment times with an index larger than 0 are considered times actually
/// achieved by the runner, while the others are artifacts of route changes and
/// similar algorithmic changes.
public class SegmentHistoryElementRefMut: SegmentHistoryElementRef {
}

/// A segment time achieved for a segment. It is tagged with an index. Only
/// segment times with an index larger than 0 are considered times actually
/// achieved by the runner, while the others are artifacts of route changes and
/// similar algorithmic changes.
public class SegmentHistoryElement : SegmentHistoryElementRefMut {
    private func drop() {
        if self.ptr != nil {
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// Iterates over all the segment times of a segment and their indices.
public class SegmentHistoryIterRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// Iterates over all the segment times of a segment and their indices.
public class SegmentHistoryIterRefMut: SegmentHistoryIterRef {
    /// Accesses the next Segment History element. Returns nil if there are no
    /// more elements.
    public func next() -> SegmentHistoryElementRef? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SegmentHistoryIter_next(self.ptr)
        if result == nil {
            return nil
        }
        return SegmentHistoryElementRef(ptr: result)
    }
}

/// Iterates over all the segment times of a segment and their indices.
public class SegmentHistoryIter : SegmentHistoryIterRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.SegmentHistoryIter_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// The Segment Time Component is a component that shows the time for the current
/// segment in a comparison of your choosing. If no comparison is specified it
/// uses the timer's current comparison.
public class SegmentTimeComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Encodes the component's state information as JSON.
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.SegmentTimeComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state based on the timer provided.
    public func state(_ timer: TimerRef) -> KeyValueComponentState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.SegmentTimeComponent_state(self.ptr, timer.ptr)
        return KeyValueComponentState(ptr: result)
    }
}

/// The Segment Time Component is a component that shows the time for the current
/// segment in a comparison of your choosing. If no comparison is specified it
/// uses the timer's current comparison.
public class SegmentTimeComponentRefMut: SegmentTimeComponentRef {
}

/// The Segment Time Component is a component that shows the time for the current
/// segment in a comparison of your choosing. If no comparison is specified it
/// uses the timer's current comparison.
public class SegmentTimeComponent : SegmentTimeComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.SegmentTimeComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Segment Time Component.
    public init() {
        let result = CLiveSplitCore.SegmentTimeComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SegmentTimeComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// The Separator Component is a simple component that only serves to render
/// separators between components.
public class SeparatorComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// The Separator Component is a simple component that only serves to render
/// separators between components.
public class SeparatorComponentRefMut: SeparatorComponentRef {
    /// Calculates the component's state.
    public func state() -> SeparatorComponentState {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SeparatorComponent_state(self.ptr)
        return SeparatorComponentState(ptr: result)
    }
}

/// The Separator Component is a simple component that only serves to render
/// separators between components.
public class SeparatorComponent : SeparatorComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.SeparatorComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Separator Component.
    public init() {
        let result = CLiveSplitCore.SeparatorComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SeparatorComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// The state object describes the information to visualize for this component.
public class SeparatorComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// The state object describes the information to visualize for this component.
public class SeparatorComponentStateRefMut: SeparatorComponentStateRef {
}

/// The state object describes the information to visualize for this component.
public class SeparatorComponentState : SeparatorComponentStateRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.SeparatorComponentState_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// Describes a setting's value. Such a value can be of a variety of different
/// types.
public class SettingValueRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Encodes this Setting Value's state as JSON.
    public func asJson() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SettingValue_as_json(self.ptr)
        return String(cString: result!)
    }
}

/// Describes a setting's value. Such a value can be of a variety of different
/// types.
public class SettingValueRefMut: SettingValueRef {
}

/// Describes a setting's value. Such a value can be of a variety of different
/// types.
public class SettingValue : SettingValueRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.SettingValue_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new setting value from a boolean value.
    public static func fromBool(_ value: Bool) -> SettingValue {
        let result = CLiveSplitCore.SettingValue_from_bool(value)
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from an unsigned integer.
    public static func fromUint(_ value: UInt32) -> SettingValue {
        let result = CLiveSplitCore.SettingValue_from_uint(value)
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from a signed integer.
    public static func fromInt(_ value: Int32) -> SettingValue {
        let result = CLiveSplitCore.SettingValue_from_int(value)
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from a string.
    public static func fromString(_ value: String) -> SettingValue {
        let result = CLiveSplitCore.SettingValue_from_string(value)
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from a string that has the type `optional string`.
    public static func fromOptionalString(_ value: String) -> SettingValue {
        let result = CLiveSplitCore.SettingValue_from_optional_string(value)
        return SettingValue(ptr: result)
    }
    /// Creates a new empty setting value that has the type `optional string`.
    public static func fromOptionalEmptyString() -> SettingValue {
        let result = CLiveSplitCore.SettingValue_from_optional_empty_string()
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from an accuracy name. If it doesn't match a
    /// known accuracy, nil is returned.
    public static func fromAccuracy(_ value: String) -> SettingValue? {
        let result = CLiveSplitCore.SettingValue_from_accuracy(value)
        if result == nil {
            return nil
        }
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from a digits format name. If it doesn't match a
    /// known digits format, nil is returned.
    public static func fromDigitsFormat(_ value: String) -> SettingValue? {
        let result = CLiveSplitCore.SettingValue_from_digits_format(value)
        if result == nil {
            return nil
        }
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from a timing method name with the type
    /// `optional timing method`. If it doesn't match a known timing method, nil
    /// is returned.
    public static func fromOptionalTimingMethod(_ value: String) -> SettingValue? {
        let result = CLiveSplitCore.SettingValue_from_optional_timing_method(value)
        if result == nil {
            return nil
        }
        return SettingValue(ptr: result)
    }
    /// Creates a new empty setting value with the type `optional timing method`.
    public static func fromOptionalEmptyTimingMethod() -> SettingValue {
        let result = CLiveSplitCore.SettingValue_from_optional_empty_timing_method()
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from the color provided as RGBA.
    public static func fromColor(_ r: Float, _ g: Float, _ b: Float, _ a: Float) -> SettingValue {
        let result = CLiveSplitCore.SettingValue_from_color(r, g, b, a)
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from the color provided as RGBA with the type
    /// `optional color`.
    public static func fromOptionalColor(_ r: Float, _ g: Float, _ b: Float, _ a: Float) -> SettingValue {
        let result = CLiveSplitCore.SettingValue_from_optional_color(r, g, b, a)
        return SettingValue(ptr: result)
    }
    /// Creates a new empty setting value with the type `optional color`.
    public static func fromOptionalEmptyColor() -> SettingValue {
        let result = CLiveSplitCore.SettingValue_from_optional_empty_color()
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value that is a transparent gradient.
    public static func fromTransparentGradient() -> SettingValue {
        let result = CLiveSplitCore.SettingValue_from_transparent_gradient()
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from the vertical gradient provided as two RGBA colors.
    public static func fromVerticalGradient(_ r1: Float, _ g1: Float, _ b1: Float, _ a1: Float, _ r2: Float, _ g2: Float, _ b2: Float, _ a2: Float) -> SettingValue {
        let result = CLiveSplitCore.SettingValue_from_vertical_gradient(r1, g1, b1, a1, r2, g2, b2, a2)
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from the horizontal gradient provided as two RGBA colors.
    public static func fromHorizontalGradient(_ r1: Float, _ g1: Float, _ b1: Float, _ a1: Float, _ r2: Float, _ g2: Float, _ b2: Float, _ a2: Float) -> SettingValue {
        let result = CLiveSplitCore.SettingValue_from_horizontal_gradient(r1, g1, b1, a1, r2, g2, b2, a2)
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from the alternating gradient provided as two RGBA colors.
    public static func fromAlternatingGradient(_ r1: Float, _ g1: Float, _ b1: Float, _ a1: Float, _ r2: Float, _ g2: Float, _ b2: Float, _ a2: Float) -> SettingValue {
        let result = CLiveSplitCore.SettingValue_from_alternating_gradient(r1, g1, b1, a1, r2, g2, b2, a2)
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from the alignment name provided. If it doesn't
    /// match a known alignment, nil is returned.
    public static func fromAlignment(_ value: String) -> SettingValue? {
        let result = CLiveSplitCore.SettingValue_from_alignment(value)
        if result == nil {
            return nil
        }
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from the column start with name provided. If it
    /// doesn't match a known column start with, nil is returned.
    public static func fromColumnStartWith(_ value: String) -> SettingValue? {
        let result = CLiveSplitCore.SettingValue_from_column_start_with(value)
        if result == nil {
            return nil
        }
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from the column update with name provided. If it
    /// doesn't match a known column update with, nil is returned.
    public static func fromColumnUpdateWith(_ value: String) -> SettingValue? {
        let result = CLiveSplitCore.SettingValue_from_column_update_with(value)
        if result == nil {
            return nil
        }
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from the column update trigger. If it doesn't
    /// match a known column update trigger, nil is returned.
    public static func fromColumnUpdateTrigger(_ value: String) -> SettingValue? {
        let result = CLiveSplitCore.SettingValue_from_column_update_trigger(value)
        if result == nil {
            return nil
        }
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value from the layout direction. If it doesn't
    /// match a known layout direction, nil is returned.
    public static func fromLayoutDirection(_ value: String) -> SettingValue? {
        let result = CLiveSplitCore.SettingValue_from_layout_direction(value)
        if result == nil {
            return nil
        }
        return SettingValue(ptr: result)
    }
    /// Creates a new setting value with the type `font`.
    public static func fromFont(_ family: String, _ style: String, _ weight: String, _ stretch: String) -> SettingValue? {
        let result = CLiveSplitCore.SettingValue_from_font(family, style, weight, stretch)
        if result == nil {
            return nil
        }
        return SettingValue(ptr: result)
    }
    /// Creates a new empty setting value with the type `font`.
    public static func fromEmptyFont() -> SettingValue {
        let result = CLiveSplitCore.SettingValue_from_empty_font()
        return SettingValue(ptr: result)
    }
}

/// A Shared Timer that can be used to share a single timer object with multiple
/// owners.
public class SharedTimerRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Creates a new shared timer handle that shares the same timer. The inner
    /// timer object only gets disposed when the final handle gets disposed.
    public func share() -> SharedTimer {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SharedTimer_share(self.ptr)
        return SharedTimer(ptr: result)
    }
    /// Requests read access to the timer that is being shared. This blocks the
    /// thread as long as there is an active write lock. Dispose the read lock when
    /// you are done using the timer.
    public func read() -> TimerReadLock {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SharedTimer_read(self.ptr)
        return TimerReadLock(ptr: result)
    }
    /// Requests write access to the timer that is being shared. This blocks the
    /// thread as long as there are active write or read locks. Dispose the write
    /// lock when you are done using the timer.
    public func write() -> TimerWriteLock {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SharedTimer_write(self.ptr)
        return TimerWriteLock(ptr: result)
    }
    /// Replaces the timer that is being shared by the timer provided. This blocks
    /// the thread as long as there are active write or read locks. Everyone who is
    /// sharing the old timer will share the provided timer after successful
    /// completion.
    public func replaceInner(_ timer: LSTimer) {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        CLiveSplitCore.SharedTimer_replace_inner(self.ptr, timer.ptr)
        timer.ptr = nil
    }
    public func readWith(_ block: (TimerRef) -> ()) {
        let lock = self.read()
        block(lock.timer())
        lock.dispose()
    }
    public func writeWith(_ block: (TimerRefMut) -> ()) {
        let lock = self.write()
        block(lock.timer())
        lock.dispose()
    }
}

/// A Shared Timer that can be used to share a single timer object with multiple
/// owners.
public class SharedTimerRefMut: SharedTimerRef {
}

/// A Shared Timer that can be used to share a single timer object with multiple
/// owners.
public class SharedTimer : SharedTimerRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.SharedTimer_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// The software renderer allows rendering layouts entirely on the CPU. This is
/// surprisingly fast and can be considered the default renderer.
public class SoftwareRendererRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// The software renderer allows rendering layouts entirely on the CPU. This is
/// surprisingly fast and can be considered the default renderer.
public class SoftwareRendererRefMut: SoftwareRendererRef {
    /// Renders the layout state provided into the image buffer provided. The image
    /// has to be an array of RGBA8 encoded pixels (red, green, blue, alpha with
    /// each channel being an u8). Some frameworks may over allocate an image's
    /// dimensions. So an image with dimensions 100x50 may be over allocated as
    /// 128x64. In that case you provide the real dimensions of 100x50 as the width
    /// and height, but a stride of 128 pixels as that correlates with the real
    /// width of the underlying buffer. By default the renderer will try not to
    /// redraw parts of the image that haven't changed. You can force a redraw in
    /// case the image provided or its contents have changed.
    public func render(_ layoutState: LayoutStateRef, _ data: UnsafeMutableRawPointer?, _ width: UInt32, _ height: UInt32, _ stride: UInt32, _ forceRedraw: Bool) {
        assert(self.ptr != nil)
        assert(layoutState.ptr != nil)
        CLiveSplitCore.SoftwareRenderer_render(self.ptr, layoutState.ptr, data, width, height, stride, forceRedraw)
    }
}

/// The software renderer allows rendering layouts entirely on the CPU. This is
/// surprisingly fast and can be considered the default renderer.
public class SoftwareRenderer : SoftwareRendererRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.SoftwareRenderer_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new software renderer.
    public init() {
        let result = CLiveSplitCore.SoftwareRenderer_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/// The Splits Component is the main component for visualizing all the split
/// times. Each segment is shown in a tabular fashion showing the segment icon,
/// segment name, the delta compared to the chosen comparison, and the split
/// time. The list provides scrolling functionality, so not every segment needs
/// to be shown all the time.
public class SplitsComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// The Splits Component is the main component for visualizing all the split
/// times. Each segment is shown in a tabular fashion showing the segment icon,
/// segment name, the delta compared to the chosen comparison, and the split
/// time. The list provides scrolling functionality, so not every segment needs
/// to be shown all the time.
public class SplitsComponentRefMut: SplitsComponentRef {
    /// Encodes the component's state information as JSON.
    public func stateAsJson(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        assert(layoutSettings.ptr != nil)
        let result = CLiveSplitCore.SplitsComponent_state_as_json(self.ptr, timer.ptr, layoutSettings.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state based on the timer and layout settings
    /// provided.
    public func state(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> SplitsComponentState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        assert(layoutSettings.ptr != nil)
        let result = CLiveSplitCore.SplitsComponent_state(self.ptr, timer.ptr, layoutSettings.ptr)
        return SplitsComponentState(ptr: result)
    }
    /// Scrolls up the window of the segments that are shown. Doesn't move the
    /// scroll window if it reaches the top of the segments.
    public func scrollUp() {
        assert(self.ptr != nil)
        CLiveSplitCore.SplitsComponent_scroll_up(self.ptr)
    }
    /// Scrolls down the window of the segments that are shown. Doesn't move the
    /// scroll window if it reaches the bottom of the segments.
    public func scrollDown() {
        assert(self.ptr != nil)
        CLiveSplitCore.SplitsComponent_scroll_down(self.ptr)
    }
    /// The amount of segments to show in the list at any given time. If this is
    /// set to 0, all the segments are shown. If this is set to a number lower
    /// than the total amount of segments, only a certain window of all the
    /// segments is shown. This window can scroll up or down.
    public func setVisualSplitCount(_ count: size_t) {
        assert(self.ptr != nil)
        CLiveSplitCore.SplitsComponent_set_visual_split_count(self.ptr, count)
    }
    /// If there's more segments than segments that are shown, the window
    /// showing the segments automatically scrolls up and down when the current
    /// segment changes. This count determines the minimum number of future
    /// segments to be shown in this scrolling window when it automatically
    /// scrolls.
    public func setSplitPreviewCount(_ count: size_t) {
        assert(self.ptr != nil)
        CLiveSplitCore.SplitsComponent_set_split_preview_count(self.ptr, count)
    }
    /// If not every segment is shown in the scrolling window of segments, then
    /// this determines whether the final segment is always to be shown, as it
    /// contains valuable information about the total duration of the chosen
    /// comparison, which is often the runner's Personal Best.
    public func setAlwaysShowLastSplit(_ alwaysShowLastSplit: Bool) {
        assert(self.ptr != nil)
        CLiveSplitCore.SplitsComponent_set_always_show_last_split(self.ptr, alwaysShowLastSplit)
    }
    /// If the last segment is to always be shown, this determines whether to
    /// show a more pronounced separator in front of the last segment, if it is
    /// not directly adjacent to the segment shown right before it in the
    /// scrolling window.
    public func setSeparatorLastSplit(_ separatorLastSplit: Bool) {
        assert(self.ptr != nil)
        CLiveSplitCore.SplitsComponent_set_separator_last_split(self.ptr, separatorLastSplit)
    }
}

/// The Splits Component is the main component for visualizing all the split
/// times. Each segment is shown in a tabular fashion showing the segment icon,
/// segment name, the delta compared to the chosen comparison, and the split
/// time. The list provides scrolling functionality, so not every segment needs
/// to be shown all the time.
public class LSSplitsComponent : SplitsComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.SplitsComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Splits Component.
    public init() {
        let result = CLiveSplitCore.SplitsComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SplitsComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// The state object that describes a single segment's information to visualize.
public class SplitsComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Describes whether a more pronounced separator should be shown in front of
    /// the last segment provided.
    public func finalSeparatorShown() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SplitsComponentState_final_separator_shown(self.ptr)
        return result
    }
    /// Returns the amount of segments to visualize.
    public func len() -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SplitsComponentState_len(self.ptr)
        return result
    }
    /// Returns the amount of icon changes that happened in this state object.
    public func iconChangeCount() -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SplitsComponentState_icon_change_count(self.ptr)
        return result
    }
    /// Accesses the index of the segment of the icon change with the specified
    /// index. This is based on the index in the run, not on the index of the
    /// SplitState in the State object. The corresponding index is the index field
    /// of the SplitState object. You may not provide an out of bounds index.
    public func iconChangeSegmentIndex(_ iconChangeIndex: size_t) -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SplitsComponentState_icon_change_segment_index(self.ptr, iconChangeIndex)
        return result
    }
    /// The icon data of the segment of the icon change with the specified index.
    /// The buffer may be empty. This indicates that there is no icon. You may not
    /// provide an out of bounds index.
    public func iconChangeIconPtr(_ iconChangeIndex: size_t) -> UnsafeMutableRawPointer? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SplitsComponentState_icon_change_icon_ptr(self.ptr, iconChangeIndex)
        return result
    }
    /// The length of the icon data of the segment of the icon change with the
    /// specified index.
    public func iconChangeIconLen(_ iconChangeIndex: size_t) -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SplitsComponentState_icon_change_icon_len(self.ptr, iconChangeIndex)
        return result
    }
    /// The name of the segment with the specified index. You may not provide an out
    /// of bounds index.
    public func name(_ index: size_t) -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SplitsComponentState_name(self.ptr, index)
        return String(cString: result!)
    }
    /// The amount of columns to visualize for the segment with the specified index.
    /// The columns are specified from right to left. You may not provide an out of
    /// bounds index. The amount of columns to visualize may differ from segment to
    /// segment.
    public func columnsLen(_ index: size_t) -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SplitsComponentState_columns_len(self.ptr, index)
        return result
    }
    /// The column's value to show for the split and column with the specified
    /// index. The columns are specified from right to left. You may not provide an
    /// out of bounds index.
    public func columnValue(_ index: size_t, _ columnIndex: size_t) -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SplitsComponentState_column_value(self.ptr, index, columnIndex)
        return String(cString: result!)
    }
    /// The semantic coloring information the column's value carries of the segment
    /// and column with the specified index. The columns are specified from right to
    /// left. You may not provide an out of bounds index.
    public func columnSemanticColor(_ index: size_t, _ columnIndex: size_t) -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SplitsComponentState_column_semantic_color(self.ptr, index, columnIndex)
        return String(cString: result!)
    }
    /// Describes if the segment with the specified index is the segment the active
    /// attempt is currently on.
    public func isCurrentSplit(_ index: size_t) -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SplitsComponentState_is_current_split(self.ptr, index)
        return result
    }
}

/// The state object that describes a single segment's information to visualize.
public class SplitsComponentStateRefMut: SplitsComponentStateRef {
}

/// The state object that describes a single segment's information to visualize.
public class SplitsComponentState : SplitsComponentStateRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.SplitsComponentState_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// A Sum of Best Cleaner allows you to interactively remove potential issues in
/// the Segment History that lead to an inaccurate Sum of Best. If you skip a
/// split, whenever you get to the next split, the combined segment time might
/// be faster than the sum of the individual best segments. The Sum of Best
/// Cleaner will point out all of occurrences of this and allows you to delete
/// them individually if any of them seem wrong.
public class SumOfBestCleanerRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// A Sum of Best Cleaner allows you to interactively remove potential issues in
/// the Segment History that lead to an inaccurate Sum of Best. If you skip a
/// split, whenever you get to the next split, the combined segment time might
/// be faster than the sum of the individual best segments. The Sum of Best
/// Cleaner will point out all of occurrences of this and allows you to delete
/// them individually if any of them seem wrong.
public class SumOfBestCleanerRefMut: SumOfBestCleanerRef {
    /// Returns the next potential clean up. If there are no more potential
    /// clean ups, nil is returned.
    public func nextPotentialCleanUp() -> PotentialCleanUp? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SumOfBestCleaner_next_potential_clean_up(self.ptr)
        if result == nil {
            return nil
        }
        return PotentialCleanUp(ptr: result)
    }
    /// Applies a clean up to the Run.
    public func apply(_ cleanUp: PotentialCleanUp) {
        assert(self.ptr != nil)
        assert(cleanUp.ptr != nil)
        CLiveSplitCore.SumOfBestCleaner_apply(self.ptr, cleanUp.ptr)
        cleanUp.ptr = nil
    }
}

/// A Sum of Best Cleaner allows you to interactively remove potential issues in
/// the Segment History that lead to an inaccurate Sum of Best. If you skip a
/// split, whenever you get to the next split, the combined segment time might
/// be faster than the sum of the individual best segments. The Sum of Best
/// Cleaner will point out all of occurrences of this and allows you to delete
/// them individually if any of them seem wrong.
public class SumOfBestCleaner : SumOfBestCleanerRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.SumOfBestCleaner_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// The Sum of Best Segments Component shows the fastest possible time to
/// complete a run of this category, based on information collected from all the
/// previous attempts. This often matches up with the sum of the best segment
/// times of all the segments, but that may not always be the case, as skipped
/// segments may introduce combined segments that may be faster than the actual
/// sum of their best segment times. The name is therefore a bit misleading, but
/// sticks around for historical reasons.
public class SumOfBestComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Encodes the component's state information as JSON.
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.SumOfBestComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state based on the timer provided.
    public func state(_ timer: TimerRef) -> KeyValueComponentState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.SumOfBestComponent_state(self.ptr, timer.ptr)
        return KeyValueComponentState(ptr: result)
    }
}

/// The Sum of Best Segments Component shows the fastest possible time to
/// complete a run of this category, based on information collected from all the
/// previous attempts. This often matches up with the sum of the best segment
/// times of all the segments, but that may not always be the case, as skipped
/// segments may introduce combined segments that may be faster than the actual
/// sum of their best segment times. The name is therefore a bit misleading, but
/// sticks around for historical reasons.
public class SumOfBestComponentRefMut: SumOfBestComponentRef {
}

/// The Sum of Best Segments Component shows the fastest possible time to
/// complete a run of this category, based on information collected from all the
/// previous attempts. This often matches up with the sum of the best segment
/// times of all the segments, but that may not always be the case, as skipped
/// segments may introduce combined segments that may be faster than the actual
/// sum of their best segment times. The name is therefore a bit misleading, but
/// sticks around for historical reasons.
public class LSSumOfBestComponent : SumOfBestComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.SumOfBestComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Sum of Best Segments Component.
    public init() {
        let result = CLiveSplitCore.SumOfBestComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.SumOfBestComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// The Text Component simply visualizes any given text. This can either be a
/// single centered text, or split up into a left and right text, which is
/// suitable for a situation where you have a label and a value.
public class TextComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Encodes the component's state information as JSON.
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.TextComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state.
    public func state(_ timer: TimerRef) -> TextComponentState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.TextComponent_state(self.ptr, timer.ptr)
        return TextComponentState(ptr: result)
    }
}

/// The Text Component simply visualizes any given text. This can either be a
/// single centered text, or split up into a left and right text, which is
/// suitable for a situation where you have a label and a value.
public class TextComponentRefMut: TextComponentRef {
    /// Sets the centered text. If the current mode is split, it is switched to
    /// centered mode.
    public func setCenter(_ text: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.TextComponent_set_center(self.ptr, text)
    }
    /// Sets the left text. If the current mode is centered, it is switched to
    /// split mode, with the right text being empty.
    public func setLeft(_ text: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.TextComponent_set_left(self.ptr, text)
    }
    /// Sets the right text. If the current mode is centered, it is switched to
    /// split mode, with the left text being empty.
    public func setRight(_ text: String) {
        assert(self.ptr != nil)
        CLiveSplitCore.TextComponent_set_right(self.ptr, text)
    }
}

/// The Text Component simply visualizes any given text. This can either be a
/// single centered text, or split up into a left and right text, which is
/// suitable for a situation where you have a label and a value.
public class TextComponent : TextComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.TextComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Text Component.
    public init() {
        let result = CLiveSplitCore.TextComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TextComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// The state object describes the information to visualize for this component.
public class TextComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Accesses the left part of the text. If the text isn't split up, an empty
    /// string is returned instead.
    public func left() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TextComponentState_left(self.ptr)
        return String(cString: result!)
    }
    /// Accesses the right part of the text. If the text isn't split up, an empty
    /// string is returned instead.
    public func right() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TextComponentState_right(self.ptr)
        return String(cString: result!)
    }
    /// Accesses the centered text. If the text isn't centered, an empty string is
    /// returned instead.
    public func center() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TextComponentState_center(self.ptr)
        return String(cString: result!)
    }
    /// Returns whether the text is split up into a left and right part.
    public func isSplit() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TextComponentState_is_split(self.ptr)
        return result
    }
}

/// The state object describes the information to visualize for this component.
public class TextComponentStateRefMut: TextComponentStateRef {
}

/// The state object describes the information to visualize for this component.
public class TextComponentState : TextComponentStateRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.TextComponentState_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// A time that can store a Real Time and a Game Time. Both of them are
/// optional.
public class TimeRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Clones the time.
    public func clone() -> Time {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Time_clone(self.ptr)
        return Time(ptr: result)
    }
    /// The Real Time value. This may be nil if this time has no Real Time value.
    public func realTime() -> TimeSpanRef? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Time_real_time(self.ptr)
        if result == nil {
            return nil
        }
        return TimeSpanRef(ptr: result)
    }
    /// The Game Time value. This may be nil if this time has no Game Time value.
    public func gameTime() -> TimeSpanRef? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Time_game_time(self.ptr)
        if result == nil {
            return nil
        }
        return TimeSpanRef(ptr: result)
    }
    /// Access the time's value for the timing method specified.
    public func index(_ timingMethod: UInt8) -> TimeSpanRef? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Time_index(self.ptr, timingMethod)
        if result == nil {
            return nil
        }
        return TimeSpanRef(ptr: result)
    }
}

/// A time that can store a Real Time and a Game Time. Both of them are
/// optional.
public class TimeRefMut: TimeRef {
}

/// A time that can store a Real Time and a Game Time. Both of them are
/// optional.
public class Time : TimeRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.Time_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// A Time Span represents a certain span of time.
public class TimeSpanRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Clones the Time Span.
    public func clone() -> TimeSpan {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TimeSpan_clone(self.ptr)
        return TimeSpan(ptr: result)
    }
    /// Returns the total amount of seconds (including decimals) this Time Span
    /// represents.
    public func totalSeconds() -> Double {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TimeSpan_total_seconds(self.ptr)
        return result
    }
}

/// A Time Span represents a certain span of time.
public class TimeSpanRefMut: TimeSpanRef {
}

/// A Time Span represents a certain span of time.
public class TimeSpan : TimeSpanRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.TimeSpan_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Time Span from a given amount of seconds.
    public static func fromSeconds(_ seconds: Double) -> TimeSpan {
        let result = CLiveSplitCore.TimeSpan_from_seconds(seconds)
        return TimeSpan(ptr: result)
    }
    /// Parses a Time Span from a string. Returns nil if the time can't be
    /// parsed.
    public static func parse(_ text: String) -> TimeSpan? {
        let result = CLiveSplitCore.TimeSpan_parse(text)
        if result == nil {
            return nil
        }
        return TimeSpan(ptr: result)
    }
}

/// A Timer provides all the capabilities necessary for doing speedrun attempts.
public class TimerRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Accesses the index of the split the attempt is currently on. If there's
    /// no attempt in progress, `-1` is returned instead. This returns an
    /// index that is equal to the amount of segments when the attempt is
    /// finished, but has not been reset. So you need to be careful when using
    /// this value for indexing.
    public func currentSplitIndex() -> ptrdiff_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Timer_current_split_index(self.ptr)
        return result
    }
    /// Returns the currently selected Timing Method.
    public func currentTimingMethod() -> UInt8 {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Timer_current_timing_method(self.ptr)
        return result
    }
    /// Returns the current comparison that is being compared against. This may
    /// be a custom comparison or one of the Comparison Generators.
    public func currentComparison() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Timer_current_comparison(self.ptr)
        return String(cString: result!)
    }
    /// Returns whether Game Time is currently initialized. Game Time
    /// automatically gets uninitialized for each new attempt.
    public func isGameTimeInitialized() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Timer_is_game_time_initialized(self.ptr)
        return result
    }
    /// Returns whether the Game Timer is currently paused. If the Game Timer is
    /// not paused, it automatically increments similar to Real Time.
    public func isGameTimePaused() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Timer_is_game_time_paused(self.ptr)
        return result
    }
    /// Accesses the loading times. Loading times are defined as Game Time - Real Time.
    public func loadingTimes() -> TimeSpanRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Timer_loading_times(self.ptr)
        return TimeSpanRef(ptr: result)
    }
    /// Returns the current Timer Phase.
    public func currentPhase() -> UInt8 {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Timer_current_phase(self.ptr)
        return result
    }
    /// Accesses the Run in use by the Timer.
    public func getRun() -> RunRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Timer_get_run(self.ptr)
        return RunRef(ptr: result)
    }
    /// Saves the Run in use by the Timer as a LiveSplit splits file (*.lss).
    public func saveAsLss() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Timer_save_as_lss(self.ptr)
        return String(cString: result!)
    }
    /// Prints out debug information representing the whole state of the Timer. This
    /// is being written to stdout.
    public func printDebug() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_print_debug(self.ptr)
    }
    /// Returns the current time of the Timer. The Game Time is nil if the Game
    /// Time has not been initialized.
    public func currentTime() -> TimeRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Timer_current_time(self.ptr)
        return TimeRef(ptr: result)
    }
}

/// A Timer provides all the capabilities necessary for doing speedrun attempts.
public class TimerRefMut: TimerRef {
    /// Replaces the Run object used by the Timer with the Run object provided. If
    /// the Run provided contains no segments, it can't be used for timing and is
    /// not being modified. Otherwise the Run that was in use by the Timer gets
    /// stored in the Run object provided. Before the Run is returned, the current
    /// attempt is reset and the splits are being updated depending on the
    /// `update_splits` parameter. The return value indicates whether the Run got
    /// replaced successfully.
    public func replaceRun(_ run: RunRefMut, _ updateSplits: Bool) -> Bool {
        assert(self.ptr != nil)
        assert(run.ptr != nil)
        let result = CLiveSplitCore.Timer_replace_run(self.ptr, run.ptr, updateSplits)
        return result
    }
    /// Sets the Run object used by the Timer with the Run object provided. If the
    /// Run provided contains no segments, it can't be used for timing and gets
    /// returned again. If the Run object can be set, the original Run object in use
    /// by the Timer is disposed by this method and nil is returned.
    public func setRun(_ run: Run) -> Run? {
        assert(self.ptr != nil)
        assert(run.ptr != nil)
        let result = CLiveSplitCore.Timer_set_run(self.ptr, run.ptr)
        run.ptr = nil
        if result == nil {
            return nil
        }
        return Run(ptr: result)
    }
    /// Starts the Timer if there is no attempt in progress. If that's not the
    /// case, nothing happens.
    public func start() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_start(self.ptr)
    }
    /// If an attempt is in progress, stores the current time as the time of the
    /// current split. The attempt ends if the last split time is stored.
    public func split() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_split(self.ptr)
    }
    /// Starts a new attempt or stores the current time as the time of the
    /// current split. The attempt ends if the last split time is stored.
    public func splitOrStart() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_split_or_start(self.ptr)
    }
    /// Skips the current split if an attempt is in progress and the
    /// current split is not the last split.
    public func skipSplit() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_skip_split(self.ptr)
    }
    /// Removes the split time from the last split if an attempt is in progress
    /// and there is a previous split. The Timer Phase also switches to
    /// `Running` if it previously was `Ended`.
    public func undoSplit() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_undo_split(self.ptr)
    }
    /// Resets the current attempt if there is one in progress. If the splits
    /// are to be updated, all the information of the current attempt is stored
    /// in the Run's history. Otherwise the current attempt's information is
    /// discarded.
    public func reset(_ updateSplits: Bool) {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_reset(self.ptr, updateSplits)
    }
    /// Resets the current attempt if there is one in progress. The splits are
    /// updated such that the current attempt's split times are being stored as
    /// the new Personal Best.
    public func resetAndSetAttemptAsPb() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_reset_and_set_attempt_as_pb(self.ptr)
    }
    /// Pauses an active attempt that is not paused.
    public func pause() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_pause(self.ptr)
    }
    /// Resumes an attempt that is paused.
    public func resume() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_resume(self.ptr)
    }
    /// Toggles an active attempt between `Paused` and `Running`.
    public func togglePause() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_toggle_pause(self.ptr)
    }
    /// Toggles an active attempt between `Paused` and `Running` or starts an
    /// attempt if there's none in progress.
    public func togglePauseOrStart() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_toggle_pause_or_start(self.ptr)
    }
    /// Removes all the pause times from the current time. If the current
    /// attempt is paused, it also resumes that attempt. Additionally, if the
    /// attempt is finished, the final split time is adjusted to not include the
    /// pause times as well.
    /// 
    /// # Warning
    /// 
    /// This behavior is not entirely optimal, as generally only the final split
    /// time is modified, while all other split times are left unmodified, which
    /// may not be what actually happened during the run.
    public func undoAllPauses() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_undo_all_pauses(self.ptr)
    }
    /// Sets the current Timing Method to the Timing Method provided.
    public func setCurrentTimingMethod(_ method: UInt8) {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_set_current_timing_method(self.ptr, method)
    }
    /// Switches the current comparison to the next comparison in the list.
    public func switchToNextComparison() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_switch_to_next_comparison(self.ptr)
    }
    /// Switches the current comparison to the previous comparison in the list.
    public func switchToPreviousComparison() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_switch_to_previous_comparison(self.ptr)
    }
    /// Initializes Game Time for the current attempt. Game Time automatically
    /// gets uninitialized for each new attempt.
    public func initializeGameTime() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_initialize_game_time(self.ptr)
    }
    /// Deinitializes Game Time for the current attempt.
    public func deinitializeGameTime() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_deinitialize_game_time(self.ptr)
    }
    /// Pauses the Game Timer such that it doesn't automatically increment
    /// similar to Real Time.
    public func pauseGameTime() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_pause_game_time(self.ptr)
    }
    /// Resumes the Game Timer such that it automatically increments similar to
    /// Real Time, starting from the Game Time it was paused at.
    public func resumeGameTime() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_resume_game_time(self.ptr)
    }
    /// Sets the Game Time to the time specified. This also works if the Game
    /// Time is paused, which can be used as a way of updating the Game Timer
    /// periodically without it automatically moving forward. This ensures that
    /// the Game Timer never shows any time that is not coming from the game.
    public func setGameTime(_ time: TimeSpanRef) {
        assert(self.ptr != nil)
        assert(time.ptr != nil)
        CLiveSplitCore.Timer_set_game_time(self.ptr, time.ptr)
    }
    /// Instead of setting the Game Time directly, this method can be used to
    /// just specify the amount of time the game has been loading. The Game Time
    /// is then automatically determined by Real Time - Loading Times.
    public func setLoadingTimes(_ time: TimeSpanRef) {
        assert(self.ptr != nil)
        assert(time.ptr != nil)
        CLiveSplitCore.Timer_set_loading_times(self.ptr, time.ptr)
    }
    /// Marks the Run as unmodified, so that it is known that all the changes
    /// have been saved.
    public func markAsUnmodified() {
        assert(self.ptr != nil)
        CLiveSplitCore.Timer_mark_as_unmodified(self.ptr)
    }
}

/// A Timer provides all the capabilities necessary for doing speedrun attempts.
public class LSTimer : TimerRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.Timer_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Timer based on a Run object storing all the information
    /// about the splits. The Run object needs to have at least one segment, so
    /// that the Timer can store the final time. If a Run object with no
    /// segments is provided, the Timer creation fails and nil is returned.
    public init?(_ run: Run) {
        assert(run.ptr != nil)
        let result = CLiveSplitCore.Timer_new(run.ptr)
        run.ptr = nil
        if result == nil {
            return nil
        }
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Consumes the Timer and creates a Shared Timer that can be shared across
    /// multiple threads with multiple owners.
    public func intoShared() -> SharedTimer {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Timer_into_shared(self.ptr)
        self.ptr = nil
        return SharedTimer(ptr: result)
    }
    /// Takes out the Run from the Timer and resets the current attempt if there
    /// is one in progress. If the splits are to be updated, all the information
    /// of the current attempt is stored in the Run's history. Otherwise the
    /// current attempt's information is discarded.
    public func intoRun(_ updateSplits: Bool) -> Run {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.Timer_into_run(self.ptr, updateSplits)
        self.ptr = nil
        return Run(ptr: result)
    }
}

/// The Timer Component is a component that shows the total time of the current
/// attempt as a digital clock. The color of the time shown is based on a how
/// well the current attempt is doing compared to the chosen comparison.
public class TimerComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Encodes the component's state information as JSON.
    public func stateAsJson(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        assert(layoutSettings.ptr != nil)
        let result = CLiveSplitCore.TimerComponent_state_as_json(self.ptr, timer.ptr, layoutSettings.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state based on the timer and the layout
    /// settings provided.
    public func state(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> TimerComponentState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        assert(layoutSettings.ptr != nil)
        let result = CLiveSplitCore.TimerComponent_state(self.ptr, timer.ptr, layoutSettings.ptr)
        return TimerComponentState(ptr: result)
    }
}

/// The Timer Component is a component that shows the total time of the current
/// attempt as a digital clock. The color of the time shown is based on a how
/// well the current attempt is doing compared to the chosen comparison.
public class TimerComponentRefMut: TimerComponentRef {
}

/// The Timer Component is a component that shows the total time of the current
/// attempt as a digital clock. The color of the time shown is based on a how
/// well the current attempt is doing compared to the chosen comparison.
public class TimerComponent : TimerComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.TimerComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Timer Component.
    public init() {
        let result = CLiveSplitCore.TimerComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TimerComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// The state object describes the information to visualize for this component.
public class TimerComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// The time shown by the component without the fractional part.
    public func time() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TimerComponentState_time(self.ptr)
        return String(cString: result!)
    }
    /// The fractional part of the time shown (including the dot).
    public func fraction() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TimerComponentState_fraction(self.ptr)
        return String(cString: result!)
    }
    /// The semantic coloring information the time carries.
    public func semanticColor() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TimerComponentState_semantic_color(self.ptr)
        return String(cString: result!)
    }
}

/// The state object describes the information to visualize for this component.
public class TimerComponentStateRefMut: TimerComponentStateRef {
}

/// The state object describes the information to visualize for this component.
public class TimerComponentState : TimerComponentStateRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.TimerComponentState_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// A Timer Read Lock allows temporary read access to a timer. Dispose this to
/// release the read lock.
public class TimerReadLockRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// Accesses the timer.
    public func timer() -> TimerRef {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TimerReadLock_timer(self.ptr)
        return TimerRef(ptr: result)
    }
}

/// A Timer Read Lock allows temporary read access to a timer. Dispose this to
/// release the read lock.
public class TimerReadLockRefMut: TimerReadLockRef {
}

/// A Timer Read Lock allows temporary read access to a timer. Dispose this to
/// release the read lock.
public class TimerReadLock : TimerReadLockRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.TimerReadLock_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// A Timer Write Lock allows temporary write access to a timer. Dispose this to
/// release the write lock.
public class TimerWriteLockRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// A Timer Write Lock allows temporary write access to a timer. Dispose this to
/// release the write lock.
public class TimerWriteLockRefMut: TimerWriteLockRef {
    /// Accesses the timer.
    public func timer() -> TimerRefMut {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TimerWriteLock_timer(self.ptr)
        return TimerRefMut(ptr: result)
    }
}

/// A Timer Write Lock allows temporary write access to a timer. Dispose this to
/// release the write lock.
public class TimerWriteLock : TimerWriteLockRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.TimerWriteLock_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// The Title Component is a component that shows the name of the game and the
/// category that is being run. Additionally, the game icon, the attempt count,
/// and the total number of successfully finished runs can be shown.
public class TitleComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// The Title Component is a component that shows the name of the game and the
/// category that is being run. Additionally, the game icon, the attempt count,
/// and the total number of successfully finished runs can be shown.
public class TitleComponentRefMut: TitleComponentRef {
    /// Encodes the component's state information as JSON.
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.TitleComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state based on the timer provided.
    public func state(_ timer: TimerRef) -> TitleComponentState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.TitleComponent_state(self.ptr, timer.ptr)
        return TitleComponentState(ptr: result)
    }
}

/// The Title Component is a component that shows the name of the game and the
/// category that is being run. Additionally, the game icon, the attempt count,
/// and the total number of successfully finished runs can be shown.
public class LSTitleComponent : TitleComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.TitleComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Title Component.
    public init() {
        let result = CLiveSplitCore.TitleComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TitleComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}

/// The state object describes the information to visualize for this component.
public class TitleComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
    /// The data of the game's icon. This value is only specified whenever the icon
    /// changes. If you explicitly want to query this value, remount the component.
    /// The buffer may be empty. This indicates that there is no icon. If no change
    /// occurred, nil is returned instead.
    public func iconChangePtr() -> UnsafeMutableRawPointer? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TitleComponentState_icon_change_ptr(self.ptr)
        return result
    }
    /// The length of the game's icon data.
    public func iconChangeLen() -> size_t {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TitleComponentState_icon_change_len(self.ptr)
        return result
    }
    /// The first title line to show. This is either the game's name, or a
    /// combination of the game's name and the category.
    public func line1() -> String {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TitleComponentState_line1(self.ptr)
        return String(cString: result!)
    }
    /// By default the category name is shown on the second line. Based on the
    /// settings, it can however instead be shown in a single line together with
    /// the game name. In that case nil is returned instead.
    public func line2() -> String? {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TitleComponentState_line2(self.ptr)
        if let result = result {
            return String(cString: result)
        }
        return nil
    }
    /// Specifies whether the title should centered or aligned to the left
    /// instead.
    public func isCentered() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TitleComponentState_is_centered(self.ptr)
        return result
    }
    /// Returns whether the amount of successfully finished attempts is supposed to
    /// be shown.
    public func showsFinishedRuns() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TitleComponentState_shows_finished_runs(self.ptr)
        return result
    }
    /// Returns the amount of successfully finished attempts.
    public func finishedRuns() -> UInt32 {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TitleComponentState_finished_runs(self.ptr)
        return result
    }
    /// Returns whether the amount of total attempts is supposed to be shown.
    public func showsAttempts() -> Bool {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TitleComponentState_shows_attempts(self.ptr)
        return result
    }
    /// Returns the amount of total attempts.
    public func attempts() -> UInt32 {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TitleComponentState_attempts(self.ptr)
        return result
    }
}

/// The state object describes the information to visualize for this component.
public class TitleComponentStateRefMut: TitleComponentStateRef {
}

/// The state object describes the information to visualize for this component.
public class TitleComponentState : TitleComponentStateRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.TitleComponentState_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
}

/// The Total Playtime Component is a component that shows the total amount of
/// time that the current category has been played for.
public class TotalPlaytimeComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/// The Total Playtime Component is a component that shows the total amount of
/// time that the current category has been played for.
public class TotalPlaytimeComponentRefMut: TotalPlaytimeComponentRef {
    /// Encodes the component's state information as JSON.
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.TotalPlaytimeComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /// Calculates the component's state based on the timer provided.
    public func state(_ timer: TimerRef) -> KeyValueComponentState {
        assert(self.ptr != nil)
        assert(timer.ptr != nil)
        let result = CLiveSplitCore.TotalPlaytimeComponent_state(self.ptr, timer.ptr)
        return KeyValueComponentState(ptr: result)
    }
}

/// The Total Playtime Component is a component that shows the total amount of
/// time that the current category has been played for.
public class TotalPlaytimeComponent : TotalPlaytimeComponentRefMut {
    private func drop() {
        if self.ptr != nil {
            CLiveSplitCore.TotalPlaytimeComponent_drop(self.ptr)
            self.ptr = nil
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /// Creates a new Total Playtime Component.
    public init() {
        let result = CLiveSplitCore.TotalPlaytimeComponent_new()
        super.init(ptr: result)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
    /// Converts the component into a generic component suitable for using with a
    /// layout.
    public func intoGeneric() -> Component {
        assert(self.ptr != nil)
        let result = CLiveSplitCore.TotalPlaytimeComponent_into_generic(self.ptr)
        self.ptr = nil
        return Component(ptr: result)
    }
}
