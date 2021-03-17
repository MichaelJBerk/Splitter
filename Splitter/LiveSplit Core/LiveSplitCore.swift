import LiveSplitCoreNative

/**
    The analysis module provides a variety of functions for calculating
    information about runs.
*/
public class AnalysisRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The analysis module provides a variety of functions for calculating
    information about runs.
*/
public class AnalysisRefMut: AnalysisRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The analysis module provides a variety of functions for calculating
    information about runs.
*/
public class Analysis : AnalysisRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Calculates the Sum of Best Segments for the timing method provided. This is
        the fastest time possible to complete a run of a category, based on
        information collected from all the previous attempts. This often matches up
        with the sum of the best segment times of all the segments, but that may not
        always be the case, as skipped segments may introduce combined segments that
        may be faster than the actual sum of their best segment times. The name is
        therefore a bit misleading, but sticks around for historical reasons. You
        can choose to do a simple calculation instead, which excludes the Segment
        History from the calculation process. If there's an active attempt, you can
        choose to take it into account as well. Can return nil.
    */
    public static func calculateSumOfBest(_ run: RunRef, _ simpleCalculation: Bool, _ useCurrentRun: Bool, _ method: UInt8) -> TimeSpan? {
        assert(run.ptr != Optional.none)
        let result = TimeSpan(ptr: LiveSplitCoreNative.Analysis_calculate_sum_of_best(run.ptr, simpleCalculation ? true : false, useCurrentRun ? true : false, method))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Calculates the total playtime of the passed Run.
    */
    public static func calculateTotalPlaytimeForRun(_ run: RunRef) -> TimeSpan {
        assert(run.ptr != Optional.none)
        let result = TimeSpan(ptr: LiveSplitCoreNative.Analysis_calculate_total_playtime_for_run(run.ptr))
        return result
    }
    /**
        Calculates the total playtime of the passed Timer.
    */
    public static func calculateTotalPlaytimeForTimer(_ timer: TimerRef) -> TimeSpan {
        assert(timer.ptr != Optional.none)
        let result = TimeSpan(ptr: LiveSplitCoreNative.Analysis_calculate_total_playtime_for_timer(timer.ptr))
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    An Atomic Date Time represents a UTC Date Time that tries to be as close to
    an atomic clock as possible.
*/
public class AtomicDateTimeRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Represents whether the date time is actually properly derived from an
        atomic clock. If the synchronization with the atomic clock didn't happen
        yet or failed, this is set to false.
    */
    public func isSynchronized() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.AtomicDateTime_is_synchronized(self.ptr) != false
        return result
    }
    /**
        Converts this atomic date time into a RFC 2822 formatted date time.
    */
    public func toRfc2822() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.AtomicDateTime_to_rfc2822(self.ptr)
        return String(cString: result!)
    }
    /**
        Converts this atomic date time into a RFC 3339 formatted date time.
    */
    public func toRfc3339() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.AtomicDateTime_to_rfc3339(self.ptr)
        return String(cString: result!)
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    An Atomic Date Time represents a UTC Date Time that tries to be as close to
    an atomic clock as possible.
*/
public class AtomicDateTimeRefMut: AtomicDateTimeRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    An Atomic Date Time represents a UTC Date Time that tries to be as close to
    an atomic clock as possible.
*/
public class AtomicDateTime : AtomicDateTimeRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.AtomicDateTime_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    An Attempt describes information about an attempt to run a specific category
    by a specific runner in the past. Every time a new attempt is started and
    then reset, an Attempt describing general information about it is created.
*/
public class AttemptRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Accesses the unique index of the attempt. This index is unique for the
        Run, not for all of them.
    */
    public func index() -> Int32 {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Attempt_index(self.ptr)
        return result
    }
    /**
        Accesses the split time of the last segment. If the attempt got reset
        early and didn't finish, this may be empty.
    */
    public func time() -> TimeRef {
        assert(self.ptr != Optional.none)
        let result = TimeRef(ptr: LiveSplitCoreNative.Attempt_time(self.ptr))
        return result
    }
    /**
        Accesses the amount of time the attempt has been paused for. If it is not
        known, this returns nil. This means that it may not necessarily be
        possible to differentiate whether a Run has not been paused or it simply
        wasn't stored.
    */
    public func pauseTime() -> TimeSpanRef? {
        assert(self.ptr != Optional.none)
        let result = TimeSpanRef(ptr: LiveSplitCoreNative.Attempt_pause_time(self.ptr))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Accesses the point in time the attempt was started at. This returns nil
        if this information is not known.
    */
    public func started() -> AtomicDateTime? {
        assert(self.ptr != Optional.none)
        let result = AtomicDateTime(ptr: LiveSplitCoreNative.Attempt_started(self.ptr))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Accesses the point in time the attempt was ended at. This returns nil if
        this information is not known.
    */
    public func ended() -> AtomicDateTime? {
        assert(self.ptr != Optional.none)
        let result = AtomicDateTime(ptr: LiveSplitCoreNative.Attempt_ended(self.ptr))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    An Attempt describes information about an attempt to run a specific category
    by a specific runner in the past. Every time a new attempt is started and
    then reset, an Attempt describing general information about it is created.
*/
public class AttemptRefMut: AttemptRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    An Attempt describes information about an attempt to run a specific category
    by a specific runner in the past. Every time a new attempt is started and
    then reset, an Attempt describing general information about it is created.
*/
public class Attempt : AttemptRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Blank Space Component is simply an empty component that doesn't show
    anything other than a background. It mostly serves as padding between other
    components.
*/
public class BlankSpaceComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Blank Space Component is simply an empty component that doesn't show
    anything other than a background. It mostly serves as padding between other
    components.
*/
public class BlankSpaceComponentRefMut: BlankSpaceComponentRef {
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.BlankSpaceComponent_state_as_json(self.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state.
    */
    public func state() -> BlankSpaceComponentState {
        assert(self.ptr != Optional.none)
        let result = BlankSpaceComponentState(ptr: LiveSplitCoreNative.BlankSpaceComponent_state(self.ptr))
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Blank Space Component is simply an empty component that doesn't show
    anything other than a background. It mostly serves as padding between other
    components.
*/
public class BlankSpaceComponent : BlankSpaceComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.BlankSpaceComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Blank Space Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.BlankSpaceComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.BlankSpaceComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class BlankSpaceComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        The size of the component.
    */
    public func size() -> UInt32 {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.BlankSpaceComponentState_size(self.ptr)
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class BlankSpaceComponentStateRefMut: BlankSpaceComponentStateRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class BlankSpaceComponentState : BlankSpaceComponentStateRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.BlankSpaceComponentState_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Component provides information about a run in a way that is easy to
    visualize. This type can store any of the components provided by this crate.
*/
public class ComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    A Component provides information about a run in a way that is easy to
    visualize. This type can store any of the components provided by this crate.
*/
public class ComponentRefMut: ComponentRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Component provides information about a run in a way that is easy to
    visualize. This type can store any of the components provided by this crate.
*/
public class Component : ComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.Component_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Current Comparison Component is a component that shows the name of the
    comparison that is currently selected to be compared against.
*/
public class CurrentComparisonComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Current Comparison Component is a component that shows the name of the
    comparison that is currently selected to be compared against.
*/
public class CurrentComparisonComponentRefMut: CurrentComparisonComponentRef {
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = LiveSplitCoreNative.CurrentComparisonComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state based on the timer provided.
    */
    public func state(_ timer: TimerRef) -> KeyValueComponentState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = KeyValueComponentState(ptr: LiveSplitCoreNative.CurrentComparisonComponent_state(self.ptr, timer.ptr))
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Current Comparison Component is a component that shows the name of the
    comparison that is currently selected to be compared against.
*/
public class CurrentComparisonComponent : CurrentComparisonComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.CurrentComparisonComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Current Comparison Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.CurrentComparisonComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.CurrentComparisonComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Current Pace Component is a component that shows a prediction of the
    current attempt's final time, if the current attempt's pace matches the
    chosen comparison for the remainder of the run.
*/
public class CurrentPaceComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Current Pace Component is a component that shows a prediction of the
    current attempt's final time, if the current attempt's pace matches the
    chosen comparison for the remainder of the run.
*/
public class CurrentPaceComponentRefMut: CurrentPaceComponentRef {
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = LiveSplitCoreNative.CurrentPaceComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state based on the timer provided.
    */
    public func state(_ timer: TimerRef) -> KeyValueComponentState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = KeyValueComponentState(ptr: LiveSplitCoreNative.CurrentPaceComponent_state(self.ptr, timer.ptr))
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Current Pace Component is a component that shows a prediction of the
    current attempt's final time, if the current attempt's pace matches the
    chosen comparison for the remainder of the run.
*/
public class CurrentPaceComponent : CurrentPaceComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.CurrentPaceComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Current Pace Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.CurrentPaceComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.CurrentPaceComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Delta Component is a component that shows the how far ahead or behind
    the current attempt is compared to the chosen comparison.
*/
public class DeltaComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Delta Component is a component that shows the how far ahead or behind
    the current attempt is compared to the chosen comparison.
*/
public class DeltaComponentRefMut: DeltaComponentRef {
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        assert(layoutSettings.ptr != Optional.none)
        let result = LiveSplitCoreNative.DeltaComponent_state_as_json(self.ptr, timer.ptr, layoutSettings.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state based on the timer and the layout
        settings provided.
    */
    public func state(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> KeyValueComponentState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        assert(layoutSettings.ptr != Optional.none)
        let result = KeyValueComponentState(ptr: LiveSplitCoreNative.DeltaComponent_state(self.ptr, timer.ptr, layoutSettings.ptr))
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Delta Component is a component that shows the how far ahead or behind
    the current attempt is compared to the chosen comparison.
*/
public class DeltaComponent : DeltaComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.DeltaComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Delta Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.DeltaComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.DeltaComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Detailed Timer Component is a component that shows two timers, one for
    the total time of the current attempt and one showing the time of just the
    current segment. Other information, like segment times of up to two
    comparisons, the segment icon, and the segment's name, can also be shown.
*/
public class DetailedTimerComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Detailed Timer Component is a component that shows two timers, one for
    the total time of the current attempt and one showing the time of just the
    current segment. Other information, like segment times of up to two
    comparisons, the segment icon, and the segment's name, can also be shown.
*/
public class DetailedTimerComponentRefMut: DetailedTimerComponentRef {
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        assert(layoutSettings.ptr != Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponent_state_as_json(self.ptr, timer.ptr, layoutSettings.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state based on the timer and layout settings
        provided.
    */
    public func state(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> DetailedTimerComponentState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        assert(layoutSettings.ptr != Optional.none)
        let result = DetailedTimerComponentState(ptr: LiveSplitCoreNative.DetailedTimerComponent_state(self.ptr, timer.ptr, layoutSettings.ptr))
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Detailed Timer Component is a component that shows two timers, one for
    the total time of the current attempt and one showing the time of just the
    current segment. Other information, like segment times of up to two
    comparisons, the segment icon, and the segment's name, can also be shown.
*/
public class DetailedTimerComponent : DetailedTimerComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.DetailedTimerComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Detailed Timer Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.DetailedTimerComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class DetailedTimerComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        The time shown by the component's main timer without the fractional part.
    */
    public func timerTime() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponentState_timer_time(self.ptr)
        return String(cString: result!)
    }
    /**
        The fractional part of the time shown by the main timer (including the dot).
    */
    public func timerFraction() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponentState_timer_fraction(self.ptr)
        return String(cString: result!)
    }
    /**
        The semantic coloring information the main timer's time carries.
    */
    public func timerSemanticColor() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponentState_timer_semantic_color(self.ptr)
        return String(cString: result!)
    }
    /**
        The time shown by the component's segment timer without the fractional part.
    */
    public func segmentTimerTime() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponentState_segment_timer_time(self.ptr)
        return String(cString: result!)
    }
    /**
        The fractional part of the time shown by the segment timer (including the
        dot).
    */
    public func segmentTimerFraction() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponentState_segment_timer_fraction(self.ptr)
        return String(cString: result!)
    }
    /**
        Returns whether the first comparison is visible.
    */
    public func comparison1Visible() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponentState_comparison1_visible(self.ptr) != false
        return result
    }
    /**
        Returns the name of the first comparison. You may not call this if the first
        comparison is not visible.
    */
    public func comparison1Name() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponentState_comparison1_name(self.ptr)
        return String(cString: result!)
    }
    /**
        Returns the time of the first comparison. You may not call this if the first
        comparison is not visible.
    */
    public func comparison1Time() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponentState_comparison1_time(self.ptr)
        return String(cString: result!)
    }
    /**
        Returns whether the second comparison is visible.
    */
    public func comparison2Visible() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponentState_comparison2_visible(self.ptr) != false
        return result
    }
    /**
        Returns the name of the second comparison. You may not call this if the
        second comparison is not visible.
    */
    public func comparison2Name() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponentState_comparison2_name(self.ptr)
        return String(cString: result!)
    }
    /**
        Returns the time of the second comparison. You may not call this if the
        second comparison is not visible.
    */
    public func comparison2Time() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponentState_comparison2_time(self.ptr)
        return String(cString: result!)
    }
    /**
        The data of the segment's icon. This value is only specified whenever the
        icon changes. If you explicitly want to query this value, remount the
        component. The buffer itself may be empty. This indicates that there is no
        icon.
    */
    public func iconChangePtr() -> UnsafeMutableRawPointer? {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponentState_icon_change_ptr(self.ptr)
        return result
    }
    /**
        The length of the data of the segment's icon.
    */
    public func iconChangeLen() -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponentState_icon_change_len(self.ptr)
        return result
    }
    /**
        The name of the segment. This may be nil if it's not supposed to be
        visualized.
    */
    public func segmentName() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.DetailedTimerComponentState_segment_name(self.ptr)
        return String(cString: result!)
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class DetailedTimerComponentStateRefMut: DetailedTimerComponentStateRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class DetailedTimerComponentState : DetailedTimerComponentStateRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.DetailedTimerComponentState_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    With a Fuzzy List, you can implement a fuzzy searching algorithm. The list
    stores all the items that can be searched for. With the `search` method you
    can then execute the actual fuzzy search which returns a list of all the
    elements found. This can be used to implement searching in a list of games.
*/
public class FuzzyListRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Searches for the pattern provided in the list. A list of all the
        matching elements is returned. The returned list has a maximum amount of
        elements provided to this method.
    */
    public func search(_ pattern: String, _ max: size_t) -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.FuzzyList_search(self.ptr, pattern, max)
        return String(cString: result!)
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    With a Fuzzy List, you can implement a fuzzy searching algorithm. The list
    stores all the items that can be searched for. With the `search` method you
    can then execute the actual fuzzy search which returns a list of all the
    elements found. This can be used to implement searching in a list of games.
*/
public class FuzzyListRefMut: FuzzyListRef {
    /**
        Adds a new element to the list.
    */
    public func push(_ text: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.FuzzyList_push(self.ptr, text)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    With a Fuzzy List, you can implement a fuzzy searching algorithm. The list
    stores all the items that can be searched for. With the `search` method you
    can then execute the actual fuzzy search which returns a list of all the
    elements found. This can be used to implement searching in a list of games.
*/
public class FuzzyList : FuzzyListRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.FuzzyList_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Fuzzy List.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.FuzzyList_new()
        self.ptr = result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The general settings of the layout that apply to all components.
*/
public class GeneralLayoutSettingsRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The general settings of the layout that apply to all components.
*/
public class GeneralLayoutSettingsRefMut: GeneralLayoutSettingsRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The general settings of the layout that apply to all components.
*/
public class GeneralLayoutSettings : GeneralLayoutSettingsRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.GeneralLayoutSettings_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a default general layout settings configuration.
    */
	public static func `default`() -> GeneralLayoutSettings {
        let result = GeneralLayoutSettings(ptr: LiveSplitCoreNative.GeneralLayoutSettings_default())
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Graph Component visualizes how far the current attempt has been ahead or
    behind the chosen comparison throughout the whole attempt. All the
    individual deltas are shown as points in a graph.
*/
public class GraphComponentRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        assert(layoutSettings.ptr != Optional.none)
        let result = LiveSplitCoreNative.GraphComponent_state_as_json(self.ptr, timer.ptr, layoutSettings.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state based on the timer and layout settings
        provided.
    */
    public func state(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> GraphComponentState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        assert(layoutSettings.ptr != Optional.none)
        let result = GraphComponentState(ptr: LiveSplitCoreNative.GraphComponent_state(self.ptr, timer.ptr, layoutSettings.ptr))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Graph Component visualizes how far the current attempt has been ahead or
    behind the chosen comparison throughout the whole attempt. All the
    individual deltas are shown as points in a graph.
*/
public class GraphComponentRefMut: GraphComponentRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Graph Component visualizes how far the current attempt has been ahead or
    behind the chosen comparison throughout the whole attempt. All the
    individual deltas are shown as points in a graph.
*/
public class GraphComponent : GraphComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.GraphComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Graph Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.GraphComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.GraphComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for this component.
    All the coordinates are in the range 0..1.
*/
public class GraphComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Returns the amount of points to visualize. Connect all of them to visualize
        the graph. If the live delta is active, the last point is to be interpreted
        as a preview of the next split that is about to happen. Use the partial fill
        color to visualize the region beneath that graph segment.
    */
    public func pointsLen() -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.GraphComponentState_points_len(self.ptr)
        return result
    }
    /**
        Returns the x coordinate of the point specified. You may not provide an out
        of bounds index.
    */
    public func pointX(_ index: size_t) -> Float {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.GraphComponentState_point_x(self.ptr, index)
        return result
    }
    /**
        Returns the y coordinate of the point specified. You may not provide an out
        of bounds index.
    */
    public func pointY(_ index: size_t) -> Float {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.GraphComponentState_point_y(self.ptr, index)
        return result
    }
    /**
        Describes whether the segment the point specified is visualizing achieved a
        new best segment time. Use the best segment color for it, in that case. You
        may not provide an out of bounds index.
    */
    public func pointIsBestSegment(_ index: size_t) -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.GraphComponentState_point_is_best_segment(self.ptr, index) != false
        return result
    }
    /**
        Describes how many horizontal grid lines to visualize.
    */
    public func horizontalGridLinesLen() -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.GraphComponentState_horizontal_grid_lines_len(self.ptr)
        return result
    }
    /**
        Accesses the y coordinate of the horizontal grid line specified. You may not
        provide an out of bounds index.
    */
    public func horizontalGridLine(_ index: size_t) -> Float {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.GraphComponentState_horizontal_grid_line(self.ptr, index)
        return result
    }
    /**
        Describes how many vertical grid lines to visualize.
    */
    public func verticalGridLinesLen() -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.GraphComponentState_vertical_grid_lines_len(self.ptr)
        return result
    }
    /**
        Accesses the x coordinate of the vertical grid line specified. You may not
        provide an out of bounds index.
    */
    public func verticalGridLine(_ index: size_t) -> Float {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.GraphComponentState_vertical_grid_line(self.ptr, index)
        return result
    }
    /**
        The y coordinate that separates the region that shows the times that are
        ahead of the comparison and those that are behind.
    */
    public func middle() -> Float {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.GraphComponentState_middle(self.ptr)
        return result
    }
    /**
        If the live delta is active, the last point is to be interpreted as a
        preview of the next split that is about to happen. Use the partial fill
        color to visualize the region beneath that graph segment.
    */
    public func isLiveDeltaActive() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.GraphComponentState_is_live_delta_active(self.ptr) != false
        return result
    }
    /**
        Describes whether the graph is flipped vertically. For visualizing the
        graph, this usually doesn't need to be interpreted, as this information is
        entirely encoded into the other variables.
    */
    public func isFlipped() -> Bool {
        assert(self.ptr != Optional.none)
		let result = LiveSplitCoreNative.GraphComponentState_is_flipped(self.ptr) != false
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The state object describes the information to visualize for this component.
    All the coordinates are in the range 0..1.
*/
public class GraphComponentStateRefMut: GraphComponentStateRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for this component.
    All the coordinates are in the range 0..1.
*/
public class GraphComponentState : GraphComponentStateRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.GraphComponentState_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The configuration to use for a Hotkey System. It describes with keys to use
    as hotkeys for the different actions.
*/
public class HotkeyConfigRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Encodes generic description of the settings available for the hotkey
        configuration and their current values as JSON.
    */
    public func settingsDescriptionAsJson() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.HotkeyConfig_settings_description_as_json(self.ptr)
        return String(cString: result!)
    }
    /**
        Encodes the hotkey configuration as JSON.
    */
    public func asJson() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.HotkeyConfig_as_json(self.ptr)
        return String(cString: result!)
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The configuration to use for a Hotkey System. It describes with keys to use
    as hotkeys for the different actions.
*/
public class HotkeyConfigRefMut: HotkeyConfigRef {
    /**
        Sets a setting's value by its index to the given value.
        
        false is returned if a hotkey is already in use by a different action.
        
        This panics if the type of the value to be set is not compatible with the
        type of the setting's value. A panic can also occur if the index of the
        setting provided is out of bounds.
    */
    public func setValue(_ index: size_t, _ value: SettingValue) -> Bool {
        assert(self.ptr != Optional.none)
        assert(value.ptr != Optional.none)
		let result = LiveSplitCoreNative.HotkeyConfig_set_value(self.ptr, index, value.ptr) != false
        value.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The configuration to use for a Hotkey System. It describes with keys to use
    as hotkeys for the different actions.
*/
public class HotkeyConfig : HotkeyConfigRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.HotkeyConfig_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Hotkey Configuration with default settings.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.HotkeyConfig_new()
        self.ptr = result
    }
    /**
        Parses a hotkey configuration from the given JSON description. nil is
        returned if it couldn't be parsed.
    */
    public static func parseJson(_ settings: String) -> HotkeyConfig? {
        let result = HotkeyConfig(ptr: LiveSplitCoreNative.HotkeyConfig_parse_json(settings))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Attempts to parse a hotkey configuration from a given file. nil is
        returned it couldn't be parsed. This will not close the file descriptor /
        handle.
    */
    public static func parseFileHandle(_ handle: Int64) -> HotkeyConfig? {
        let result = HotkeyConfig(ptr: LiveSplitCoreNative.HotkeyConfig_parse_file_handle(handle))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    With a Hotkey System the runner can use hotkeys on their keyboard to control
    the Timer. The hotkeys are global, so the application doesn't need to be in
    focus. The behavior of the hotkeys depends on the platform and is stubbed
    out on platforms that don't support hotkeys. You can turn off a Hotkey
    System temporarily. By default the Hotkey System is activated.
*/
public class HotkeySystemRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Returns the hotkey configuration currently in use by the Hotkey System.
    */
    public func config() -> HotkeyConfig {
        assert(self.ptr != Optional.none)
        let result = HotkeyConfig(ptr: LiveSplitCoreNative.HotkeySystem_config(self.ptr))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    With a Hotkey System the runner can use hotkeys on their keyboard to control
    the Timer. The hotkeys are global, so the application doesn't need to be in
    focus. The behavior of the hotkeys depends on the platform and is stubbed
    out on platforms that don't support hotkeys. You can turn off a Hotkey
    System temporarily. By default the Hotkey System is activated.
*/
public class HotkeySystemRefMut: HotkeySystemRef {
    /**
        Deactivates the Hotkey System. No hotkeys will go through until it gets
        activated again. If it's already deactivated, nothing happens.
    */
    public func deactivate() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.HotkeySystem_deactivate(self.ptr) != false
        return result
    }
    /**
        Activates a previously deactivated Hotkey System. If it's already
        active, nothing happens.
    */
    public func activate() -> Bool {
        assert(self.ptr != Optional.none)
		let result = LiveSplitCoreNative.HotkeySystem_activate(self.ptr) != false
        return result
    }
    /**
        Applies a new hotkey configuration to the Hotkey System. Each hotkey is
        changed to the one specified in the configuration. This operation may fail
        if you provide a hotkey configuration where a hotkey is used for multiple
        operations. Returns false if the operation failed.
    */
    public func setConfig(_ config: HotkeyConfig) -> Bool {
        assert(self.ptr != Optional.none)
        assert(config.ptr != Optional.none)
        let result = LiveSplitCoreNative.HotkeySystem_set_config(self.ptr, config.ptr) != false
        config.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    With a Hotkey System the runner can use hotkeys on their keyboard to control
    the Timer. The hotkeys are global, so the application doesn't need to be in
    focus. The behavior of the hotkeys depends on the platform and is stubbed
    out on platforms that don't support hotkeys. You can turn off a Hotkey
    System temporarily. By default the Hotkey System is activated.
*/
public class HotkeySystem : HotkeySystemRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.HotkeySystem_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Hotkey System for a Timer with the default hotkeys.
    */
    public init?(_ sharedTimer: SharedTimer) {
        super.init(ptr: Optional.none)
        assert(sharedTimer.ptr != Optional.none)
        let result = LiveSplitCoreNative.HotkeySystem_new(sharedTimer.ptr)
        sharedTimer.ptr = Optional.none
        if result == Optional.none {
            return nil
        }
        self.ptr = result
    }
    /**
        Creates a new Hotkey System for a Timer with a custom configuration for the
        hotkeys.
    */
    public static func withConfig(_ sharedTimer: SharedTimer, _ config: HotkeyConfig) -> HotkeySystem? {
        assert(sharedTimer.ptr != Optional.none)
        assert(config.ptr != Optional.none)
        let result = HotkeySystem(ptr: LiveSplitCoreNative.HotkeySystem_with_config(sharedTimer.ptr, config.ptr))
        sharedTimer.ptr = Optional.none
        config.ptr = Optional.none
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for a key value based component.
*/
public class KeyValueComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        The key to visualize.
    */
    public func key() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.KeyValueComponentState_key(self.ptr)
        return String(cString: result!)
    }
    /**
        The value to visualize.
    */
    public func value() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.KeyValueComponentState_value(self.ptr)
        return String(cString: result!)
    }
    /**
        The semantic coloring information the value carries.
    */
    public func semanticColor() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.KeyValueComponentState_semantic_color(self.ptr)
        return String(cString: result!)
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The state object describes the information to visualize for a key value based component.
*/
public class KeyValueComponentStateRefMut: KeyValueComponentStateRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for a key value based component.
*/
public class KeyValueComponentState : KeyValueComponentStateRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.KeyValueComponentState_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Layout allows you to combine multiple components together to visualize a
    variety of information the runner is interested in.
*/
public class LayoutRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Clones the layout.
    */
    public func clone() -> Layout {
        assert(self.ptr != Optional.none)
        let result = Layout(ptr: LiveSplitCoreNative.Layout_clone(self.ptr))
        return result
    }
    /**
        Encodes the settings of the layout as JSON.
    */
    public func settingsAsJson() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Layout_settings_as_json(self.ptr)
        return String(cString: result!)
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    A Layout allows you to combine multiple components together to visualize a
    variety of information the runner is interested in.
*/
public class LayoutRefMut: LayoutRef {
    /**
        Calculates and returns the layout's state based on the timer provided.
    */
    public func state(_ timer: TimerRef) -> LayoutState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = LayoutState(ptr: LiveSplitCoreNative.Layout_state(self.ptr, timer.ptr))
        return result
    }
    /**
        Updates the layout's state based on the timer provided.
    */
    public func updateState(_ state: LayoutStateRefMut, _ timer: TimerRef) {
        assert(self.ptr != Optional.none)
        assert(state.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        LiveSplitCoreNative.Layout_update_state(self.ptr, state.ptr, timer.ptr)
    }
    /**
        Updates the layout's state based on the timer provided and encodes it as
        JSON.
    */
    public func updateStateAsJson(_ state: LayoutStateRefMut, _ timer: TimerRef) -> String {
        assert(self.ptr != Optional.none)
        assert(state.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = LiveSplitCoreNative.Layout_update_state_as_json(self.ptr, state.ptr, timer.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the layout's state based on the timer provided and encodes it as
        JSON. You can use this to visualize all of the components of a layout.
    */
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = LiveSplitCoreNative.Layout_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /**
        Adds a new component to the end of the layout.
    */
    public func push(_ component: Component) {
        assert(self.ptr != Optional.none)
        assert(component.ptr != Optional.none)
        LiveSplitCoreNative.Layout_push(self.ptr, component.ptr)
        component.ptr = Optional.none
    }
    /**
        Scrolls up all the components in the layout that can be scrolled up.
    */
    public func scrollUp() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Layout_scroll_up(self.ptr)
    }
    /**
        Scrolls down all the components in the layout that can be scrolled down.
    */
    public func scrollDown() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Layout_scroll_down(self.ptr)
    }
    /**
        Remounts all the components as if they were freshly initialized. Some
        components may only provide some information whenever it changes or when
        their state is first queried. Remounting returns this information again,
        whenever the layout's state is queried the next time.
    */
    public func remount() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Layout_remount(self.ptr)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Layout allows you to combine multiple components together to visualize a
    variety of information the runner is interested in.
*/
public class Layout : LayoutRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.Layout_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new empty layout with no components.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.Layout_new()
        self.ptr = result
    }
    /**
        Creates a new default layout that contains a default set of components
        in order to provide a good default layout for runners. Which components
        are provided by this and how they are configured may change in the
        future.
    */
    public static func defaultLayout() -> Layout {
        let result = Layout(ptr: LiveSplitCoreNative.Layout_default_layout())
        return result
    }
    /**
        Parses a layout from the given JSON description of its settings. nil is
        returned if it couldn't be parsed.
    */
    public static func parseJson(_ settings: String) -> Layout? {
        let result = Layout(ptr: LiveSplitCoreNative.Layout_parse_json(settings))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Attempts to parse a layout from a given file. nil is returned it couldn't
        be parsed. This will not close the file descriptor / handle.
    */
    public static func parseFileHandle(_ handle: Int64) -> Layout? {
        let result = Layout(ptr: LiveSplitCoreNative.Layout_parse_file_handle(handle))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Parses a layout saved by the original LiveSplit. This is lossy, as not
        everything can be converted completely. nil is returned if it couldn't be
        parsed at all.
    */
    public static func parseOriginalLivesplit(_ data: UnsafeMutableRawPointer?, _ length: size_t) -> Layout? {
        let result = Layout(ptr: LiveSplitCoreNative.Layout_parse_original_livesplit(data, length))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Layout Editor allows modifying Layouts while ensuring all the different
    invariants of the Layout objects are upheld no matter what kind of
    operations are being applied. It provides the current state of the editor as
    state objects that can be visualized by any kind of User Interface.
*/
public class LayoutEditorRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Encodes the Layout Editor's state as JSON in order to visualize it.
    */
    public func stateAsJson() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.LayoutEditor_state_as_json(self.ptr)
        return String(cString: result!)
    }
    /**
        Returns the state of the Layout Editor.
    */
    public func state() -> LayoutEditorState {
        assert(self.ptr != Optional.none)
        let result = LayoutEditorState(ptr: LiveSplitCoreNative.LayoutEditor_state(self.ptr))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Layout Editor allows modifying Layouts while ensuring all the different
    invariants of the Layout objects are upheld no matter what kind of
    operations are being applied. It provides the current state of the editor as
    state objects that can be visualized by any kind of User Interface.
*/
public class LayoutEditorRefMut: LayoutEditorRef {
    /**
        Encodes the layout's state as JSON based on the timer provided. You can use
        this to visualize all of the components of a layout, while it is still being
        edited by the Layout Editor.
    */
    public func layoutStateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = LiveSplitCoreNative.LayoutEditor_layout_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /**
        Selects the component with the given index in order to modify its
        settings. Only a single component is selected at any given time. You may
        not provide an invalid index.
    */
    public func select(_ index: size_t) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.LayoutEditor_select(self.ptr, index)
    }
    /**
        Adds the component provided to the end of the layout. The newly added
        component becomes the selected component.
    */
    public func addComponent(_ component: Component) {
        assert(self.ptr != Optional.none)
        assert(component.ptr != Optional.none)
        LiveSplitCoreNative.LayoutEditor_add_component(self.ptr, component.ptr)
        component.ptr = Optional.none
    }
    /**
        Removes the currently selected component, unless there's only one
        component in the layout. The next component becomes the selected
        component. If there's none, the previous component becomes the selected
        component instead.
    */
    public func removeComponent() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.LayoutEditor_remove_component(self.ptr)
    }
    /**
        Moves the selected component up, unless the first component is selected.
    */
    public func moveComponentUp() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.LayoutEditor_move_component_up(self.ptr)
    }
    /**
        Moves the selected component down, unless the last component is
        selected.
    */
    public func moveComponentDown() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.LayoutEditor_move_component_down(self.ptr)
    }
    /**
        Moves the selected component to the index provided. You may not provide
        an invalid index.
    */
    public func moveComponent(_ dstIndex: size_t) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.LayoutEditor_move_component(self.ptr, dstIndex)
    }
    /**
        Duplicates the currently selected component. The copy gets placed right
        after the selected component and becomes the newly selected component.
    */
    public func duplicateComponent() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.LayoutEditor_duplicate_component(self.ptr)
    }
    /**
        Sets a setting's value of the selected component by its setting index
        to the given value.
        
        This panics if the type of the value to be set is not compatible with
        the type of the setting's value. A panic can also occur if the index of
        the setting provided is out of bounds.
    */
    public func setComponentSettingsValue(_ index: size_t, _ value: SettingValue) {
        assert(self.ptr != Optional.none)
        assert(value.ptr != Optional.none)
        LiveSplitCoreNative.LayoutEditor_set_component_settings_value(self.ptr, index, value.ptr)
        value.ptr = Optional.none
    }
    /**
        Sets a setting's value of the general settings by its setting index to
        the given value.
        
        This panics if the type of the value to be set is not compatible with
        the type of the setting's value. A panic can also occur if the index of
        the setting provided is out of bounds.
    */
    public func setGeneralSettingsValue(_ index: size_t, _ value: SettingValue) {
        assert(self.ptr != Optional.none)
        assert(value.ptr != Optional.none)
        LiveSplitCoreNative.LayoutEditor_set_general_settings_value(self.ptr, index, value.ptr)
        value.ptr = Optional.none
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Layout Editor allows modifying Layouts while ensuring all the different
    invariants of the Layout objects are upheld no matter what kind of
    operations are being applied. It provides the current state of the editor as
    state objects that can be visualized by any kind of User Interface.
*/
public class LayoutEditor : LayoutEditorRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Layout Editor that modifies the Layout provided. Creation of
        the Layout Editor fails when a Layout with no components is provided. In
        that case nil is returned instead.
    */
    public init?(_ layout: Layout) {
        super.init(ptr: Optional.none)
        assert(layout.ptr != Optional.none)
        let result = LiveSplitCoreNative.LayoutEditor_new(layout.ptr)
        layout.ptr = Optional.none
        if result == Optional.none {
            return nil
        }
        self.ptr = result
    }
    /**
        Closes the Layout Editor and gives back access to the modified Layout. In
        case you want to implement a Cancel Button, just dispose the Layout object
        you get here.
    */
    public func close() -> Layout {
        assert(self.ptr != Optional.none)
        let result = Layout(ptr: LiveSplitCoreNative.LayoutEditor_close(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    Represents the current state of the Layout Editor in order to visualize it properly.
*/
public class LayoutEditorStateRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Returns the number of components in the layout.
    */
    public func componentLen() -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.LayoutEditorState_component_len(self.ptr)
        return result
    }
    /**
        Returns the name of the component at the specified index.
    */
    public func componentText(_ index: size_t) -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.LayoutEditorState_component_text(self.ptr, index)
        return String(cString: result!)
    }
    /**
        Returns a bitfield corresponding to which buttons are active.
        
        The bits are as follows:
        
        * `0x04` - Can remove the current component
        * `0x02` - Can move the current component up
        * `0x01` - Can move the current component down
    */
    public func buttons() -> UInt8 {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.LayoutEditorState_buttons(self.ptr)
        return result
    }
    /**
        Returns the index of the currently selected component.
    */
    public func selectedComponent() -> UInt32 {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.LayoutEditorState_selected_component(self.ptr)
        return result
    }
    /**
        Returns the number of fields in the layout's settings.
        
        Set `component_settings` to true to use the selected component's settings instead.
    */
    public func fieldLen(_ componentSettings: Bool) -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.LayoutEditorState_field_len(self.ptr, componentSettings ? true : false)
        return result
    }
    /**
        Returns the name of the layout's setting at the specified index.
        
        Set `component_settings` to true to use the selected component's settings instead.
    */
    public func fieldText(_ componentSettings: Bool, _ index: size_t) -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.LayoutEditorState_field_text(self.ptr, componentSettings ? true : false, index)
        return String(cString: result!)
    }
    /**
        Returns the value of the layout's setting at the specified index.
        
        Set `component_settings` to true to use the selected component's settings instead.
    */
    public func fieldValue(_ componentSettings: Bool, _ index: size_t) -> SettingValueRef {
        assert(self.ptr != Optional.none)
        let result = SettingValueRef(ptr: LiveSplitCoreNative.LayoutEditorState_field_value(self.ptr, componentSettings ? true : false, index))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    Represents the current state of the Layout Editor in order to visualize it properly.
*/
public class LayoutEditorStateRefMut: LayoutEditorStateRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    Represents the current state of the Layout Editor in order to visualize it properly.
*/
public class LayoutEditorState : LayoutEditorStateRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.LayoutEditorState_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for an entire
    layout. Use this with care, as invalid usage will result in a panic.
    
    Specifically, you should avoid doing the following:
    
    - Using out of bounds indices.
    - Using the wrong getter function on the wrong type of component.
*/
public class LayoutStateRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Encodes the layout state as JSON. You can use this to visualize all of the
        components of a layout.
    */
    public func asJson() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.LayoutState_as_json(self.ptr)
        return String(cString: result!)
    }
    /**
        Gets the number of Components in the Layout State.
    */
    public func len() -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.LayoutState_len(self.ptr)
        return result
    }
    /**
        Returns a string describing the type of the Component at the specified
        index.
    */
    public func componentType(_ index: size_t) -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.LayoutState_component_type(self.ptr, index)
        return String(cString: result!)
    }
    /**
        Gets the Blank Space component state at the specified index.
    */
    public func componentAsBlankSpace(_ index: size_t) -> BlankSpaceComponentStateRef {
        assert(self.ptr != Optional.none)
        let result = BlankSpaceComponentStateRef(ptr: LiveSplitCoreNative.LayoutState_component_as_blank_space(self.ptr, index))
        return result
    }
    /**
        Gets the Detailed Timer component state at the specified index.
    */
    public func componentAsDetailedTimer(_ index: size_t) -> DetailedTimerComponentStateRef {
        assert(self.ptr != Optional.none)
        let result = DetailedTimerComponentStateRef(ptr: LiveSplitCoreNative.LayoutState_component_as_detailed_timer(self.ptr, index))
        return result
    }
    /**
        Gets the Graph component state at the specified index.
    */
    public func componentAsGraph(_ index: size_t) -> GraphComponentStateRef {
        assert(self.ptr != Optional.none)
        let result = GraphComponentStateRef(ptr: LiveSplitCoreNative.LayoutState_component_as_graph(self.ptr, index))
        return result
    }
    /**
        Gets the Key Value component state at the specified index.
    */
    public func componentAsKeyValue(_ index: size_t) -> KeyValueComponentStateRef {
        assert(self.ptr != Optional.none)
        let result = KeyValueComponentStateRef(ptr: LiveSplitCoreNative.LayoutState_component_as_key_value(self.ptr, index))
        return result
    }
    /**
        Gets the Separator component state at the specified index.
    */
    public func componentAsSeparator(_ index: size_t) -> SeparatorComponentStateRef {
        assert(self.ptr != Optional.none)
        let result = SeparatorComponentStateRef(ptr: LiveSplitCoreNative.LayoutState_component_as_separator(self.ptr, index))
        return result
    }
    /**
        Gets the Splits component state at the specified index.
    */
    public func componentAsSplits(_ index: size_t) -> SplitsComponentStateRef {
        assert(self.ptr != Optional.none)
        let result = SplitsComponentStateRef(ptr: LiveSplitCoreNative.LayoutState_component_as_splits(self.ptr, index))
        return result
    }
    /**
        Gets the Text component state at the specified index.
    */
    public func componentAsText(_ index: size_t) -> TextComponentStateRef {
        assert(self.ptr != Optional.none)
        let result = TextComponentStateRef(ptr: LiveSplitCoreNative.LayoutState_component_as_text(self.ptr, index))
        return result
    }
    /**
        Gets the Timer component state at the specified index.
    */
    public func componentAsTimer(_ index: size_t) -> TimerComponentStateRef {
        assert(self.ptr != Optional.none)
        let result = TimerComponentStateRef(ptr: LiveSplitCoreNative.LayoutState_component_as_timer(self.ptr, index))
        return result
    }
    /**
        Gets the Title component state at the specified index.
    */
    public func componentAsTitle(_ index: size_t) -> TitleComponentStateRef {
        assert(self.ptr != Optional.none)
        let result = TitleComponentStateRef(ptr: LiveSplitCoreNative.LayoutState_component_as_title(self.ptr, index))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The state object describes the information to visualize for an entire
    layout. Use this with care, as invalid usage will result in a panic.
    
    Specifically, you should avoid doing the following:
    
    - Using out of bounds indices.
    - Using the wrong getter function on the wrong type of component.
*/
public class LayoutStateRefMut: LayoutStateRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for an entire
    layout. Use this with care, as invalid usage will result in a panic.
    
    Specifically, you should avoid doing the following:
    
    - Using out of bounds indices.
    - Using the wrong getter function on the wrong type of component.
*/
public class LayoutState : LayoutStateRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.LayoutState_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new empty Layout State. This is useful for creating an empty
        layout state that gets updated over time.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.LayoutState_new()
        self.ptr = result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A run parsed by the Composite Parser. This contains the Run itself and
    information about which parser parsed it.
*/
public class ParseRunResultRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Returns true if the Run got parsed successfully. false is returned otherwise.
    */
    public func parsedSuccessfully() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.ParseRunResult_parsed_successfully(self.ptr) != false
        return result
    }
    /**
        Accesses the name of the Parser that parsed the Run. You may not call this
        if the Run wasn't parsed successfully.
    */
    public func timerKind() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.ParseRunResult_timer_kind(self.ptr)
        return String(cString: result!)
    }
    /**
        Checks whether the Parser parsed a generic timer. Since a generic timer can
        have any name, it may clash with the specific timer formats that
        livesplit-core supports. With this function you can determine if a generic
        timer format was parsed, instead of one of the more specific timer formats.
    */
    public func isGenericTimer() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.ParseRunResult_is_generic_timer(self.ptr) != false
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    A run parsed by the Composite Parser. This contains the Run itself and
    information about which parser parsed it.
*/
public class ParseRunResultRefMut: ParseRunResultRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A run parsed by the Composite Parser. This contains the Run itself and
    information about which parser parsed it.
*/
public class ParseRunResult : ParseRunResultRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.ParseRunResult_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Moves the actual Run object out of the Result. You may not call this if the
        Run wasn't parsed successfully.
    */
    public func unwrap() -> Run {
        assert(self.ptr != Optional.none)
        let result = Run(ptr: LiveSplitCoreNative.ParseRunResult_unwrap(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The PB Chance Component is a component that shows how likely it is to beat
    the Personal Best. If there is no active attempt it shows the general chance
    of beating the Personal Best. During an attempt it actively changes based on
    how well the attempt is going.
*/
public class PbChanceComponentRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = LiveSplitCoreNative.PbChanceComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state based on the timer provided.
    */
    public func state(_ timer: TimerRef) -> KeyValueComponentState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = KeyValueComponentState(ptr: LiveSplitCoreNative.PbChanceComponent_state(self.ptr, timer.ptr))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The PB Chance Component is a component that shows how likely it is to beat
    the Personal Best. If there is no active attempt it shows the general chance
    of beating the Personal Best. During an attempt it actively changes based on
    how well the attempt is going.
*/
public class PbChanceComponentRefMut: PbChanceComponentRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The PB Chance Component is a component that shows how likely it is to beat
    the Personal Best. If there is no active attempt it shows the general chance
    of beating the Personal Best. During an attempt it actively changes based on
    how well the attempt is going.
*/
public class PbChanceComponent : PbChanceComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.PbChanceComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new PB Chance Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.PbChanceComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.PbChanceComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Possible Time Save Component is a component that shows how much time the
    chosen comparison could've saved for the current segment, based on the Best
    Segments. This component also allows showing the Total Possible Time Save
    for the remainder of the current attempt.
*/
public class PossibleTimeSaveComponentRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = LiveSplitCoreNative.PossibleTimeSaveComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state based on the timer provided.
    */
    public func state(_ timer: TimerRef) -> KeyValueComponentState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = KeyValueComponentState(ptr: LiveSplitCoreNative.PossibleTimeSaveComponent_state(self.ptr, timer.ptr))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Possible Time Save Component is a component that shows how much time the
    chosen comparison could've saved for the current segment, based on the Best
    Segments. This component also allows showing the Total Possible Time Save
    for the remainder of the current attempt.
*/
public class PossibleTimeSaveComponentRefMut: PossibleTimeSaveComponentRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Possible Time Save Component is a component that shows how much time the
    chosen comparison could've saved for the current segment, based on the Best
    Segments. This component also allows showing the Total Possible Time Save
    for the remainder of the current attempt.
*/
public class PossibleTimeSaveComponent : PossibleTimeSaveComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.PossibleTimeSaveComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Possible Time Save Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.PossibleTimeSaveComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.PossibleTimeSaveComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    Describes a potential clean up that could be applied. You can query a
    message describing the details of this potential clean up. A potential clean
    up can then be turned into an actual clean up in order to apply it to the
    Run.
*/
public class PotentialCleanUpRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Accesses the message describing the potential clean up that can be applied
        to a Run.
    */
    public func message() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.PotentialCleanUp_message(self.ptr)
        return String(cString: result!)
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    Describes a potential clean up that could be applied. You can query a
    message describing the details of this potential clean up. A potential clean
    up can then be turned into an actual clean up in order to apply it to the
    Run.
*/
public class PotentialCleanUpRefMut: PotentialCleanUpRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    Describes a potential clean up that could be applied. You can query a
    message describing the details of this potential clean up. A potential clean
    up can then be turned into an actual clean up in order to apply it to the
    Run.
*/
public class PotentialCleanUp : PotentialCleanUpRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.PotentialCleanUp_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Previous Segment Component is a component that shows how much time was
    saved or lost during the previous segment based on the chosen comparison.
    Additionally, the potential time save for the previous segment can be
    displayed. This component switches to a `Live Segment` view that shows
    active time loss whenever the runner is losing time on the current segment.
*/
public class PreviousSegmentComponentRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        assert(layoutSettings.ptr != Optional.none)
        let result = LiveSplitCoreNative.PreviousSegmentComponent_state_as_json(self.ptr, timer.ptr, layoutSettings.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state based on the timer and the layout
        settings provided.
    */
    public func state(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> KeyValueComponentState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        assert(layoutSettings.ptr != Optional.none)
        let result = KeyValueComponentState(ptr: LiveSplitCoreNative.PreviousSegmentComponent_state(self.ptr, timer.ptr, layoutSettings.ptr))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Previous Segment Component is a component that shows how much time was
    saved or lost during the previous segment based on the chosen comparison.
    Additionally, the potential time save for the previous segment can be
    displayed. This component switches to a `Live Segment` view that shows
    active time loss whenever the runner is losing time on the current segment.
*/
public class PreviousSegmentComponentRefMut: PreviousSegmentComponentRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Previous Segment Component is a component that shows how much time was
    saved or lost during the previous segment based on the chosen comparison.
    Additionally, the potential time save for the previous segment can be
    displayed. This component switches to a `Live Segment` view that shows
    active time loss whenever the runner is losing time on the current segment.
*/
public class PreviousSegmentComponent : PreviousSegmentComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.PreviousSegmentComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Previous Segment Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.PreviousSegmentComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.PreviousSegmentComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Run stores the split times for a specific game and category of a runner.
*/
public class RunRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Clones the Run object.
    */
    public func clone() -> Run {
        assert(self.ptr != Optional.none)
        let result = Run(ptr: LiveSplitCoreNative.Run_clone(self.ptr))
        return result
    }
    /**
        Accesses the name of the game this Run is for.
    */
    public func gameName() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Run_game_name(self.ptr)
        return String(cString: result!)
    }
    /**
        Accesses the game icon's data. If there is no game icon, this returns an
        empty buffer.
    */
    public func gameIconPtr() -> UnsafeMutableRawPointer? {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Run_game_icon_ptr(self.ptr)
        return result
    }
    /**
        Accesses the amount of bytes the game icon's data takes up.
    */
    public func gameIconLen() -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Run_game_icon_len(self.ptr)
        return result
    }
    /**
        Accesses the name of the category this Run is for.
    */
    public func categoryName() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Run_category_name(self.ptr)
        return String(cString: result!)
    }
    /**
        Returns a file name (without the extension) suitable for this Run that
        is built the following way:
        
        Game Name - Category Name
        
        If either is empty, the dash is omitted. Special characters that cause
        problems in file names are also omitted. If an extended category name is
        used, the variables of the category are appended in a parenthesis.
    */
    public func extendedFileName(_ useExtendedCategoryName: Bool) -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Run_extended_file_name(self.ptr, useExtendedCategoryName ? true : false)
        return String(cString: result!)
    }
    /**
        Returns a name suitable for this Run that is built the following way:
        
        Game Name - Category Name
        
        If either is empty, the dash is omitted. If an extended category name is
        used, the variables of the category are appended in a parenthesis.
    */
    public func extendedName(_ useExtendedCategoryName: Bool) -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Run_extended_name(self.ptr, useExtendedCategoryName ? true : false)
        return String(cString: result!)
    }
    /**
        Returns an extended category name that possibly includes the region,
        platform and variables, depending on the arguments provided. An extended
        category name may look like this:
        
        Any% (No Tuner, JPN, Wii Emulator)
    */
    public func extendedCategoryName(_ showRegion: Bool, _ showPlatform: Bool, _ showVariables: Bool) -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Run_extended_category_name(self.ptr, showRegion ? true : false, showPlatform ? true : false, showVariables ? true : false)
        return String(cString: result!)
    }
    /**
        Returns the amount of runs that have been attempted with these splits.
    */
    public func attemptCount() -> UInt32 {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Run_attempt_count(self.ptr)
        return result
    }
    /**
        Accesses additional metadata of this Run, like the platform and region
        of the game.
    */
    public func metadata() -> RunMetadataRef {
        assert(self.ptr != Optional.none)
        let result = RunMetadataRef(ptr: LiveSplitCoreNative.Run_metadata(self.ptr))
        return result
    }
    /**
        Accesses the time an attempt of this Run should start at.
    */
    public func offset() -> TimeSpanRef {
        assert(self.ptr != Optional.none)
        let result = TimeSpanRef(ptr: LiveSplitCoreNative.Run_offset(self.ptr))
        return result
    }
    /**
        Returns the amount of segments stored in this Run.
    */
    public func len() -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Run_len(self.ptr)
        return result
    }
    /**
        Returns whether the Run has been modified and should be saved so that the
        changes don't get lost.
    */
    public func hasBeenModified() -> Bool {
        assert(self.ptr != Optional.none)
		let result = LiveSplitCoreNative.Run_has_been_modified(self.ptr) != false
        return result
    }
    /**
        Accesses a certain segment of this Run. You may not provide an out of bounds
        index.
    */
    public func segment(_ index: size_t) -> SegmentRef {
        assert(self.ptr != Optional.none)
        let result = SegmentRef(ptr: LiveSplitCoreNative.Run_segment(self.ptr, index))
        return result
    }
    /**
        Returns the amount attempt history elements are stored in this Run.
    */
    public func attemptHistoryLen() -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Run_attempt_history_len(self.ptr)
        return result
    }
    /**
        Accesses the an attempt history element by its index. This does not store
        the actual segment times, just the overall attempt information. Information
        about the individual segments is stored within each segment. You may not
        provide an out of bounds index.
    */
    public func attemptHistoryIndex(_ index: size_t) -> AttemptRef {
        assert(self.ptr != Optional.none)
        let result = AttemptRef(ptr: LiveSplitCoreNative.Run_attempt_history_index(self.ptr, index))
        return result
    }
    /**
        Saves a Run as a LiveSplit splits file (*.lss). If the run is actively in
        use by a timer, use the appropriate method on the timer instead, in order to
        properly save the current attempt as well.
    */
    public func saveAsLss() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Run_save_as_lss(self.ptr)
        return String(cString: result!)
    }
    /**
        Returns the amount of custom comparisons stored in this Run.
    */
    public func customComparisonsLen() -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Run_custom_comparisons_len(self.ptr)
        return result
    }
    /**
        Accesses a custom comparison stored in this Run by its index. This includes
        `Personal Best` but excludes all the other Comparison Generators. You may
        not provide an out of bounds index.
    */
    public func customComparison(_ index: size_t) -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Run_custom_comparison(self.ptr, index)
        return String(cString: result!)
    }
    /**
        Accesses the Auto Splitter Settings that are encoded as XML.
    */
    public func autoSplitterSettings() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Run_auto_splitter_settings(self.ptr)
        return String(cString: result!)
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    A Run stores the split times for a specific game and category of a runner.
*/
public class RunRefMut: RunRef {
    /**
        Pushes the segment provided to the end of the list of segments of this Run.
    */
    public func pushSegment(_ segment: Segment) {
        assert(self.ptr != Optional.none)
        assert(segment.ptr != Optional.none)
        LiveSplitCoreNative.Run_push_segment(self.ptr, segment.ptr)
        segment.ptr = Optional.none
    }
    /**
        Sets the name of the game this Run is for.
    */
    public func setGameName(_ game: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Run_set_game_name(self.ptr, game)
    }
    /**
        Sets the name of the category this Run is for.
    */
    public func setCategoryName(_ category: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Run_set_category_name(self.ptr, category)
    }
    /**
        Marks the Run as modified, so that it is known that there are changes
        that should be saved.
    */
    public func markAsModified() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Run_mark_as_modified(self.ptr)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Run stores the split times for a specific game and category of a runner.
*/
public class Run : RunRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.Run_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Run object with no segments.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.Run_new()
        self.ptr = result
    }
    /**
        Attempts to parse a splits file from an array by invoking the corresponding
        parser for the file format detected. A path to the splits file can be
        provided, which helps saving the splits file again later. Additionally you
        need to specify if additional files, like external images are allowed to be
        loaded. If you are using livesplit-core in a server-like environment, set
        this to false. Only client-side applications should set this to true.
    */
    public static func parse(_ data: UnsafeMutableRawPointer?, _ length: size_t, _ path: String, _ loadFiles: Bool) -> ParseRunResult {
        let result = ParseRunResult(ptr: LiveSplitCoreNative.Run_parse(data, length, path, loadFiles ? true : false))
        return result
    }
    /**
        Attempts to parse a splits file from a file by invoking the corresponding
        parser for the file format detected. A path to the splits file can be
        provided, which helps saving the splits file again later. Additionally you
        need to specify if additional files, like external images are allowed to be
        loaded. If you are using livesplit-core in a server-like environment, set
        this to false. Only client-side applications should set this to true. On
        Unix you pass a file descriptor to this function. On Windows you pass a file
        handle to this function. The file descriptor / handle does not get closed.
    */
    public static func parseFileHandle(_ handle: Int64, _ path: String, _ loadFiles: Bool) -> ParseRunResult {
        let result = ParseRunResult(ptr: LiveSplitCoreNative.Run_parse_file_handle(handle, path, loadFiles ? true : false))
        return result
    }
	
	///  Attempts to parse a splits file from a file by invoking the corresponding parser for the file format detected.
	/// - Parameters:
	///   - path: Path to the file to be parsed
	///   - loadFiles: Should external files - such as images - be loaded
	/// - Returns: The parsed run if successful, `nil` if not
	/// - NOTE: File does not get closed
	public static func parseFile(path: String, loadFiles: Bool) -> Run? {
		if let handle = FileHandle(forReadingAtPath: path) {
			let fd = Int64(handle.fileDescriptor)
			return parseFileHandle(fd, path, loadFiles).unwrap()
		}
		return nil
		
	}
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Run Editor allows modifying Runs while ensuring that all the different
    invariants of the Run objects are upheld no matter what kind of operations
    are being applied to the Run. It provides the current state of the editor as
    state objects that can be visualized by any kind of User Interface.
*/
public class RunEditorRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Run Editor allows modifying Runs while ensuring that all the different
    invariants of the Run objects are upheld no matter what kind of operations
    are being applied to the Run. It provides the current state of the editor as
    state objects that can be visualized by any kind of User Interface.
*/
public class RunEditorRefMut: RunEditorRef {
    /**
        Calculates the Run Editor's state and encodes it as
        JSON in order to visualize it.
    */
    public func stateAsJson() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunEditor_state_as_json(self.ptr)
        return String(cString: result!)
    }
    /**
        Selects a different timing method for being modified.
    */
    public func selectTimingMethod(_ method: UInt8) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_select_timing_method(self.ptr, method)
    }
    /**
        Unselects the segment with the given index. If it's not selected or the
        index is out of bounds, nothing happens. The segment is not unselected,
        when it is the only segment that is selected. If the active segment is
        unselected, the most recently selected segment remaining becomes the
        active segment.
    */
    public func unselect(_ index: size_t) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_unselect(self.ptr, index)
    }
    /**
        In addition to the segments that are already selected, the segment with
        the given index is being selected. The segment chosen also becomes the
        active segment.
        
        This panics if the index of the segment provided is out of bounds.
    */
    public func selectAdditionally(_ index: size_t) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_select_additionally(self.ptr, index)
    }
    /**
        Selects the segment with the given index. All other segments are
        unselected. The segment chosen also becomes the active segment.
        
        This panics if the index of the segment provided is out of bounds.
    */
    public func selectOnly(_ index: size_t) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_select_only(self.ptr, index)
    }
    /**
        Sets the name of the game.
    */
    public func setGameName(_ game: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_set_game_name(self.ptr, game)
    }
    /**
        Sets the name of the category.
    */
    public func setCategoryName(_ category: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_set_category_name(self.ptr, category)
    }
    /**
        Parses and sets the timer offset from the string provided. The timer
        offset specifies the time, the timer starts at when starting a new
        attempt.
    */
    public func parseAndSetOffset(_ offset: String) -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunEditor_parse_and_set_offset(self.ptr, offset) != false
        return result
    }
    /**
        Parses and sets the attempt count from the string provided. Changing
        this has no affect on the attempt history or the segment history. This
        number is mostly just a visual number for the runner.
    */
    public func parseAndSetAttemptCount(_ attempts: String) -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunEditor_parse_and_set_attempt_count(self.ptr, attempts) != false
        return result
    }
    /**
        Sets the game's icon.
    */
    public func setGameIcon(_ data: UnsafeMutableRawPointer?, _ length: size_t) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_set_game_icon(self.ptr, data, length)
    }
    /**
        Removes the game's icon.
    */
    public func removeGameIcon() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_remove_game_icon(self.ptr)
    }
    /**
        Sets the speedrun.com Run ID of the run. You need to ensure that the
        record on speedrun.com matches up with the Personal Best of this run.
        This may be empty if there's no association.
    */
    public func setRunId(_ name: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_set_run_id(self.ptr, name)
    }
    /**
        Sets the name of the region this game is from. This may be empty if it's
        not specified.
    */
    public func setRegionName(_ name: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_set_region_name(self.ptr, name)
    }
    /**
        Sets the name of the platform this game is run on. This may be empty if
        it's not specified.
    */
    public func setPlatformName(_ name: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_set_platform_name(self.ptr, name)
    }
    /**
        Specifies whether this speedrun is done on an emulator. Keep in mind
        that false may also mean that this information is simply not known.
    */
    public func setEmulatorUsage(_ usesEmulator: Bool) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_set_emulator_usage(self.ptr, usesEmulator ? true : false)
    }
    /**
        Sets the speedrun.com variable with the name specified to the value specified. A
        variable is an arbitrary key value pair storing additional information
        about the category. An example of this may be whether Amiibos are used
        in this category. If the variable doesn't exist yet, it is being
        inserted.
    */
    public func setSpeedrunComVariable(_ name: String, _ value: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_set_speedrun_com_variable(self.ptr, name, value)
    }
    /**
        Removes the speedrun.com variable with the name specified.
    */
    public func removeSpeedrunComVariable(_ name: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_remove_speedrun_com_variable(self.ptr, name)
    }
    /**
        Adds a new permanent custom variable. If there's a temporary variable with
        the same name, it gets turned into a permanent variable and its value stays.
        If a permanent variable with the name already exists, nothing happens.
    */
    public func addCustomVariable(_ name: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_add_custom_variable(self.ptr, name)
    }
    /**
        Sets the value of a custom variable with the name specified. If the custom
        variable does not exist, or is not a permanent variable, nothing happens.
    */
    public func setCustomVariable(_ name: String, _ value: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_set_custom_variable(self.ptr, name, value)
    }
    /**
        Removes the custom variable with the name specified. If the custom variable
        does not exist, or is not a permanent variable, nothing happens.
    */
    public func removeCustomVariable(_ name: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_remove_custom_variable(self.ptr, name)
    }
    /**
        Resets all the Metadata Information.
    */
    public func clearMetadata() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_clear_metadata(self.ptr)
    }
    /**
        Inserts a new empty segment above the active segment and adjusts the
        Run's history information accordingly. The newly created segment is then
        the only selected segment and also the active segment.
    */
    public func insertSegmentAbove() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_insert_segment_above(self.ptr)
    }
    /**
        Inserts a new empty segment below the active segment and adjusts the
        Run's history information accordingly. The newly created segment is then
        the only selected segment and also the active segment.
    */
    public func insertSegmentBelow() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_insert_segment_below(self.ptr)
    }
    /**
        Removes all the selected segments, unless all of them are selected. The
        run's information is automatically adjusted properly. The next
        not-to-be-removed segment after the active segment becomes the new
        active segment. If there's none, then the next not-to-be-removed segment
        before the active segment, becomes the new active segment.
    */
    public func removeSegments() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_remove_segments(self.ptr)
    }
    /**
        Moves all the selected segments up, unless the first segment is
        selected. The run's information is automatically adjusted properly. The
        active segment stays the active segment.
    */
    public func moveSegmentsUp() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_move_segments_up(self.ptr)
    }
    /**
        Moves all the selected segments down, unless the last segment is
        selected. The run's information is automatically adjusted properly. The
        active segment stays the active segment.
    */
    public func moveSegmentsDown() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_move_segments_down(self.ptr)
    }
    /**
        Sets the icon of the active segment.
    */
    public func activeSetIcon(_ data: UnsafeMutableRawPointer?, _ length: size_t) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_active_set_icon(self.ptr, data, length)
    }
    /**
        Removes the icon of the active segment.
    */
    public func activeRemoveIcon() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_active_remove_icon(self.ptr)
    }
    /**
        Sets the name of the active segment.
    */
    public func activeSetName(_ name: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_active_set_name(self.ptr, name)
    }
    /**
        Parses a split time from a string and sets it for the active segment withLiveSplitCore.swift
        the chosen timing method.
    */
    public func activeParseAndSetSplitTime(_ time: String) -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunEditor_active_parse_and_set_split_time(self.ptr, time) != false
        return result
    }
    /**
        Parses a segment time from a string and sets it for the active segment with
        the chosen timing method.
    */
    public func activeParseAndSetSegmentTime(_ time: String) -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunEditor_active_parse_and_set_segment_time(self.ptr, time) != false
        return result
    }
    /**
        Parses a best segment time from a string and sets it for the active segment
        with the chosen timing method.
    */
    public func activeParseAndSetBestSegmentTime(_ time: String) -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunEditor_active_parse_and_set_best_segment_time(self.ptr, time) != false
        return result
    }
    /**
        Parses a comparison time for the provided comparison and sets it for the
        active active segment with the chosen timing method.
    */
    public func activeParseAndSetComparisonTime(_ comparison: String, _ time: String) -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunEditor_active_parse_and_set_comparison_time(self.ptr, comparison, time) != false
        return result
    }
    /**
        Adds a new custom comparison. It can't be added if it starts with
        `[Race]` or already exists.
    */
    public func addComparison(_ comparison: String) -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunEditor_add_comparison(self.ptr, comparison) != false
        return result
    }
    /**
        Imports the Personal Best from the provided run as a comparison. The
        comparison can't be added if its name starts with `[Race]` or it already
        exists.
    */
    public func importComparison(_ run: RunRef, _ comparison: String) -> Bool {
        assert(self.ptr != Optional.none)
        assert(run.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunEditor_import_comparison(self.ptr, run.ptr, comparison) != false
        return result
    }
    /**
        Removes the chosen custom comparison. You can't remove a Comparison
        Generator's Comparison or the Personal Best.
    */
    public func removeComparison(_ comparison: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_remove_comparison(self.ptr, comparison)
    }
    /**
        Renames a comparison. The comparison can't be renamed if the new name of
        the comparison starts with `[Race]` or it already exists.
    */
    public func renameComparison(_ oldName: String, _ newName: String) -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunEditor_rename_comparison(self.ptr, oldName, newName) != false
        return result
    }
    /**
        Reorders the custom comparisons by moving the comparison with the source
        index specified to the destination index specified. Returns false if one
        of the indices is invalid. The indices are based on the comparison names of
        the Run Editor's state.
    */
    public func moveComparison(_ srcIndex: size_t, _ dstIndex: size_t) -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunEditor_move_comparison(self.ptr, srcIndex, dstIndex) != false
        return result
    }
    /**
        Parses a goal time and generates a custom goal comparison based on the
        parsed value. The comparison's times are automatically balanced based on the
        runner's history such that it roughly represents what split times for the
        goal time would roughly look like. Since it is populated by the runner's
        history, only goal times within the sum of the best segments and the sum of
        the worst segments are supported. Everything else is automatically capped by
        that range. The comparison is only populated for the selected timing method.
        The other timing method's comparison times are not modified by this, so you
        can call this again with the other timing method to generate the comparison
        times for both timing methods.
    */
    public func parseAndGenerateGoalComparison(_ time: String) -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunEditor_parse_and_generate_goal_comparison(self.ptr, time) != false
        return result
    }
    /**
        Clears out the Attempt History and the Segment Histories of all the
        segments.
    */
    public func clearHistory() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_clear_history(self.ptr)
    }
    /**
        Clears out the Attempt History, the Segment Histories, all the times,
        sets the Attempt Count to 0 and clears the speedrun.com run id
        association. All Custom Comparisons other than `Personal Best` are
        deleted as well.
    */
    public func clearTimes() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.RunEditor_clear_times(self.ptr)
    }
    /**
        Creates a Sum of Best Cleaner which allows you to interactively remove
        potential issues in the segment history that lead to an inaccurate Sum
        of Best. If you skip a split, whenever you will do the next split, the
        combined segment time might be faster than the sum of the individual
        best segments. The Sum of Best Cleaner will point out all of these and
        allows you to delete them individually if any of them seem wrong.
    */
    public func cleanSumOfBest() -> SumOfBestCleaner {
        assert(self.ptr != Optional.none)
        let result = SumOfBestCleaner(ptr: LiveSplitCoreNative.RunEditor_clean_sum_of_best(self.ptr))
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Run Editor allows modifying Runs while ensuring that all the different
    invariants of the Run objects are upheld no matter what kind of operations
    are being applied to the Run. It provides the current state of the editor as
    state objects that can be visualized by any kind of User Interface.
*/
public class RunEditor : RunEditorRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Run Editor that modifies the Run provided. Creation of the Run
        Editor fails when a Run with no segments is provided. If a Run object with
        no segments is provided, the Run Editor creation fails and nil is
        returned.
    */
    public init?(_ run: Run) {
        super.init(ptr: Optional.none)
        assert(run.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunEditor_new(run.ptr)
        run.ptr = Optional.none
        if result == Optional.none {
            return nil
        }
        self.ptr = result
    }
    /**
        Closes the Run Editor and gives back access to the modified Run object. In
        case you want to implement a Cancel Button, just dispose the Run object you
        get here.
    */
    public func close() -> Run {
        assert(self.ptr != Optional.none)
        let result = Run(ptr: LiveSplitCoreNative.RunEditor_close(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Run Metadata stores additional information about a run, like the
    platform and region of the game. All of this information is optional.
*/
public class RunMetadataRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Accesses the speedrun.com Run ID of the run. This Run ID specify which
        Record on speedrun.com this run is associated with. This should be
        changed once the Personal Best doesn't match up with that record
        anymore. This may be empty if there's no association.
    */
    public func runId() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunMetadata_run_id(self.ptr)
        return String(cString: result!)
    }
    /**
        Accesses the name of the platform this game is run on. This may be empty
        if it's not specified.
    */
    public func platformName() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunMetadata_platform_name(self.ptr)
        return String(cString: result!)
    }
    /**
        Returns true if this speedrun is done on an emulator. However false
        may also indicate that this information is simply not known.
    */
    public func usesEmulator() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunMetadata_uses_emulator(self.ptr) != false
        return result
    }
    /**
        Accesses the name of the region this game is from. This may be empty if
        it's not specified.
    */
    public func regionName() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunMetadata_region_name(self.ptr)
        return String(cString: result!)
    }
    /**
        Returns an iterator iterating over all the speedrun.com variables and their
        values that have been specified.
    */
    public func speedrunComVariables() -> RunMetadataSpeedrunComVariablesIter {
        assert(self.ptr != Optional.none)
        let result = RunMetadataSpeedrunComVariablesIter(ptr: LiveSplitCoreNative.RunMetadata_speedrun_com_variables(self.ptr))
        return result
    }
    /**
        Returns an iterator iterating over all the custom variables and their
        values. This includes both temporary and permanent variables.
    */
    public func customVariables() -> RunMetadataCustomVariablesIter {
        assert(self.ptr != Optional.none)
        let result = RunMetadataCustomVariablesIter(ptr: LiveSplitCoreNative.RunMetadata_custom_variables(self.ptr))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Run Metadata stores additional information about a run, like the
    platform and region of the game. All of this information is optional.
*/
public class RunMetadataRefMut: RunMetadataRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Run Metadata stores additional information about a run, like the
    platform and region of the game. All of this information is optional.
*/
public class RunMetadata : RunMetadataRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A custom variable is a key value pair storing additional information about a
    run. Unlike the speedrun.com variables, these can be fully custom and don't
    need to correspond to anything on speedrun.com. Permanent custom variables
    can be specified by the runner. Additionally auto splitters or other sources
    may provide temporary custom variables that are not stored in the splits
    files.
*/
public class RunMetadataCustomVariableRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Accesses the name of this custom variable.
    */
    public func name() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunMetadataCustomVariable_name(self.ptr)
        return String(cString: result!)
    }
    /**
        Accesses the value of this custom variable.
    */
    public func value() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunMetadataCustomVariable_value(self.ptr)
        return String(cString: result!)
    }
    /**
        Returns true if the custom variable is permanent. Permanent variables get
        stored in the splits file and are visible in the run editor. Temporary
        variables are not.
    */
    public func isPermanent() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunMetadataCustomVariable_is_permanent(self.ptr) != false
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    A custom variable is a key value pair storing additional information about a
    run. Unlike the speedrun.com variables, these can be fully custom and don't
    need to correspond to anything on speedrun.com. Permanent custom variables
    can be specified by the runner. Additionally auto splitters or other sources
    may provide temporary custom variables that are not stored in the splits
    files.
*/
public class RunMetadataCustomVariableRefMut: RunMetadataCustomVariableRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A custom variable is a key value pair storing additional information about a
    run. Unlike the speedrun.com variables, these can be fully custom and don't
    need to correspond to anything on speedrun.com. Permanent custom variables
    can be specified by the runner. Additionally auto splitters or other sources
    may provide temporary custom variables that are not stored in the splits
    files.
*/
public class RunMetadataCustomVariable : RunMetadataCustomVariableRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.RunMetadataCustomVariable_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    An iterator iterating over all the custom variables and their values
    that have been specified.
*/
public class RunMetadataCustomVariablesIterRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    An iterator iterating over all the custom variables and their values
    that have been specified.
*/
public class RunMetadataCustomVariablesIterRefMut: RunMetadataCustomVariablesIterRef {
    /**
        Accesses the next custom variable. Returns nil if there are no more
        variables.
    */
    public func next() -> RunMetadataCustomVariableRef? {
        assert(self.ptr != Optional.none)
        let result = RunMetadataCustomVariableRef(ptr: LiveSplitCoreNative.RunMetadataCustomVariablesIter_next(self.ptr))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    An iterator iterating over all the custom variables and their values
    that have been specified.
*/
public class RunMetadataCustomVariablesIter : RunMetadataCustomVariablesIterRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.RunMetadataCustomVariablesIter_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A speedrun.com variable is an arbitrary key value pair storing additional
    information about the category. An example of this may be whether Amiibos
    are used in the category.
*/
public class RunMetadataSpeedrunComVariableRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Accesses the name of this speedrun.com variable.
    */
    public func name() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunMetadataSpeedrunComVariable_name(self.ptr)
        return String(cString: result!)
    }
    /**
        Accesses the value of this speedrun.com variable.
    */
    public func value() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.RunMetadataSpeedrunComVariable_value(self.ptr)
        return String(cString: result!)
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    A speedrun.com variable is an arbitrary key value pair storing additional
    information about the category. An example of this may be whether Amiibos
    are used in the category.
*/
public class RunMetadataSpeedrunComVariableRefMut: RunMetadataSpeedrunComVariableRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A speedrun.com variable is an arbitrary key value pair storing additional
    information about the category. An example of this may be whether Amiibos
    are used in the category.
*/
public class RunMetadataSpeedrunComVariable : RunMetadataSpeedrunComVariableRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.RunMetadataSpeedrunComVariable_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    An iterator iterating over all the speedrun.com variables and their values
    that have been specified.
*/
public class RunMetadataSpeedrunComVariablesIterRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    An iterator iterating over all the speedrun.com variables and their values
    that have been specified.
*/
public class RunMetadataSpeedrunComVariablesIterRefMut: RunMetadataSpeedrunComVariablesIterRef {
    /**
        Accesses the next speedrun.com variable. Returns nil if there are no more
        variables.
    */
    public func next() -> RunMetadataSpeedrunComVariableRef? {
        assert(self.ptr != Optional.none)
        let result = RunMetadataSpeedrunComVariableRef(ptr: LiveSplitCoreNative.RunMetadataSpeedrunComVariablesIter_next(self.ptr))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    An iterator iterating over all the speedrun.com variables and their values
    that have been specified.
*/
public class RunMetadataSpeedrunComVariablesIter : RunMetadataSpeedrunComVariablesIterRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.RunMetadataSpeedrunComVariablesIter_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Segment describes a point in a speedrun that is suitable for storing a
    split time. This stores the name of that segment, an icon, the split times
    of different comparisons, and a history of segment times.
*/
public class SegmentRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Accesses the name of the segment.
    */
    public func name() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Segment_name(self.ptr)
        return String(cString: result!)
    }
    /**
        Accesses the segment icon's data. If there is no segment icon, this returns
        an empty buffer.
    */
    public func iconPtr() -> UnsafeMutableRawPointer? {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Segment_icon_ptr(self.ptr)
        return result
    }
    /**
        Accesses the amount of bytes the segment icon's data takes up.
    */
    public func iconLen() -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Segment_icon_len(self.ptr)
        return result
    }
    /**
        Accesses the specified comparison's time. If there's none for this
        comparison, an empty time is being returned (but not stored in the
        segment).
    */
    public func comparison(_ comparison: String) -> TimeRef {
        assert(self.ptr != Optional.none)
        let result = TimeRef(ptr: LiveSplitCoreNative.Segment_comparison(self.ptr, comparison))
        return result
    }
    /**
        Accesses the split time of the Personal Best for this segment. If it
        doesn't exist, an empty time is returned.
    */
    public func personalBestSplitTime() -> TimeRef {
        assert(self.ptr != Optional.none)
        let result = TimeRef(ptr: LiveSplitCoreNative.Segment_personal_best_split_time(self.ptr))
        return result
    }
    /**
        Accesses the Best Segment Time.
    */
    public func bestSegmentTime() -> TimeRef {
        assert(self.ptr != Optional.none)
        let result = TimeRef(ptr: LiveSplitCoreNative.Segment_best_segment_time(self.ptr))
        return result
    }
    /**
        Accesses the Segment History of this segment.
    */
    public func segmentHistory() -> SegmentHistoryRef {
        assert(self.ptr != Optional.none)
        let result = SegmentHistoryRef(ptr: LiveSplitCoreNative.Segment_segment_history(self.ptr))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    A Segment describes a point in a speedrun that is suitable for storing a
    split time. This stores the name of that segment, an icon, the split times
    of different comparisons, and a history of segment times.
*/
public class SegmentRefMut: SegmentRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Segment describes a point in a speedrun that is suitable for storing a
    split time. This stores the name of that segment, an icon, the split times
    of different comparisons, and a history of segment times.
*/
public class Segment : SegmentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.Segment_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Segment with the name given.
    */
    public init(_ name: String) {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.Segment_new(name)
        self.ptr = result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    Stores the segment times achieved for a certain segment. Each segment is
    tagged with an index. Only segment times with an index larger than 0 are
    considered times actually achieved by the runner, while the others are
    artifacts of route changes and similar algorithmic changes.
*/
public class SegmentHistoryRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Iterates over all the segment times and their indices.
    */
    public func iter() -> SegmentHistoryIter {
        assert(self.ptr != Optional.none)
        let result = SegmentHistoryIter(ptr: LiveSplitCoreNative.SegmentHistory_iter(self.ptr))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    Stores the segment times achieved for a certain segment. Each segment is
    tagged with an index. Only segment times with an index larger than 0 are
    considered times actually achieved by the runner, while the others are
    artifacts of route changes and similar algorithmic changes.
*/
public class SegmentHistoryRefMut: SegmentHistoryRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    Stores the segment times achieved for a certain segment. Each segment is
    tagged with an index. Only segment times with an index larger than 0 are
    considered times actually achieved by the runner, while the others are
    artifacts of route changes and similar algorithmic changes.
*/
public class SegmentHistory : SegmentHistoryRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A segment time achieved for a segment. It is tagged with an index. Only
    segment times with an index larger than 0 are considered times actually
    achieved by the runner, while the others are artifacts of route changes and
    similar algorithmic changes.
*/
public class SegmentHistoryElementRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Accesses the index of the segment history element.
    */
    public func index() -> Int32 {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.SegmentHistoryElement_index(self.ptr)
        return result
    }
    /**
        Accesses the segment time of the segment history element.
    */
    public func time() -> TimeRef {
        assert(self.ptr != Optional.none)
        let result = TimeRef(ptr: LiveSplitCoreNative.SegmentHistoryElement_time(self.ptr))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    A segment time achieved for a segment. It is tagged with an index. Only
    segment times with an index larger than 0 are considered times actually
    achieved by the runner, while the others are artifacts of route changes and
    similar algorithmic changes.
*/
public class SegmentHistoryElementRefMut: SegmentHistoryElementRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A segment time achieved for a segment. It is tagged with an index. Only
    segment times with an index larger than 0 are considered times actually
    achieved by the runner, while the others are artifacts of route changes and
    similar algorithmic changes.
*/
public class SegmentHistoryElement : SegmentHistoryElementRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    Iterates over all the segment times of a segment and their indices.
*/
public class SegmentHistoryIterRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    Iterates over all the segment times of a segment and their indices.
*/
public class SegmentHistoryIterRefMut: SegmentHistoryIterRef {
    /**
        Accesses the next Segment History element. Returns nil if there are no
        more elements.
    */
    public func next() -> SegmentHistoryElementRef? {
        assert(self.ptr != Optional.none)
        let result = SegmentHistoryElementRef(ptr: LiveSplitCoreNative.SegmentHistoryIter_next(self.ptr))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    Iterates over all the segment times of a segment and their indices.
*/
public class SegmentHistoryIter : SegmentHistoryIterRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.SegmentHistoryIter_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Segment Time Component is a component that shows the time for the current
    segment in a comparison of your choosing. If no comparison is specified it
    uses the timer's current comparison.
*/
public class SegmentTimeComponentRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = LiveSplitCoreNative.SegmentTimeComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state based on the timer provided.
    */
    public func state(_ timer: TimerRef) -> KeyValueComponentState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = KeyValueComponentState(ptr: LiveSplitCoreNative.SegmentTimeComponent_state(self.ptr, timer.ptr))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Segment Time Component is a component that shows the time for the current
    segment in a comparison of your choosing. If no comparison is specified it
    uses the timer's current comparison.
*/
public class SegmentTimeComponentRefMut: SegmentTimeComponentRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Segment Time Component is a component that shows the time for the current
    segment in a comparison of your choosing. If no comparison is specified it
    uses the timer's current comparison.
*/
public class SegmentTimeComponent : SegmentTimeComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.SegmentTimeComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Segment Time Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.SegmentTimeComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.SegmentTimeComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Separator Component is a simple component that only serves to render
    separators between components.
*/
public class SeparatorComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Separator Component is a simple component that only serves to render
    separators between components.
*/
public class SeparatorComponentRefMut: SeparatorComponentRef {
    /**
        Calculates the component's state.
    */
    public func state() -> SeparatorComponentState {
        assert(self.ptr != Optional.none)
        let result = SeparatorComponentState(ptr: LiveSplitCoreNative.SeparatorComponent_state(self.ptr))
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Separator Component is a simple component that only serves to render
    separators between components.
*/
public class SeparatorComponent : SeparatorComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.SeparatorComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Separator Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.SeparatorComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.SeparatorComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class SeparatorComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class SeparatorComponentStateRefMut: SeparatorComponentStateRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class SeparatorComponentState : SeparatorComponentStateRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.SeparatorComponentState_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    Describes a setting's value. Such a value can be of a variety of different
    types.
*/
public class SettingValueRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Encodes this Setting Value's state as JSON.
    */
    public func asJson() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.SettingValue_as_json(self.ptr)
        return String(cString: result!)
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    Describes a setting's value. Such a value can be of a variety of different
    types.
*/
public class SettingValueRefMut: SettingValueRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    Describes a setting's value. Such a value can be of a variety of different
    types.
*/
public class SettingValue : SettingValueRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.SettingValue_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new setting value from a boolean value.
    */
    public static func fromBool(_ value: Bool) -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_bool(value ? true : false))
        return result
    }
    /**
        Creates a new setting value from an unsigned integer.
    */
    public static func fromUint(_ value: UInt32) -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_uint(value))
        return result
    }
    /**
        Creates a new setting value from a signed integer.
    */
    public static func fromInt(_ value: Int32) -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_int(value))
        return result
    }
    /**
        Creates a new setting value from a string.
    */
    public static func fromString(_ value: String) -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_string(value))
        return result
    }
    /**
        Creates a new setting value from a string that has the type `optional string`.
    */
    public static func fromOptionalString(_ value: String) -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_optional_string(value))
        return result
    }
    /**
        Creates a new empty setting value that has the type `optional string`.
    */
    public static func fromOptionalEmptyString() -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_optional_empty_string())
        return result
    }
    /**
        Creates a new setting value from a floating point number.
    */
    public static func fromFloat(_ value: Double) -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_float(value))
        return result
    }
    /**
        Creates a new setting value from an accuracy name. If it doesn't match a
        known accuracy, nil is returned.
    */
    public static func fromAccuracy(_ value: String) -> SettingValue? {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_accuracy(value))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Creates a new setting value from a digits format name. If it doesn't match a
        known digits format, nil is returned.
    */
    public static func fromDigitsFormat(_ value: String) -> SettingValue? {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_digits_format(value))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Creates a new setting value from a timing method name with the type
        `optional timing method`. If it doesn't match a known timing method, nil
        is returned.
    */
    public static func fromOptionalTimingMethod(_ value: String) -> SettingValue? {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_optional_timing_method(value))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Creates a new empty setting value with the type `optional timing method`.
    */
    public static func fromOptionalEmptyTimingMethod() -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_optional_empty_timing_method())
        return result
    }
    /**
        Creates a new setting value from the color provided as RGBA.
    */
    public static func fromColor(_ r: Float, _ g: Float, _ b: Float, _ a: Float) -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_color(r, g, b, a))
        return result
    }
    /**
        Creates a new setting value from the color provided as RGBA with the type
        `optional color`.
    */
    public static func fromOptionalColor(_ r: Float, _ g: Float, _ b: Float, _ a: Float) -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_optional_color(r, g, b, a))
        return result
    }
    /**
        Creates a new empty setting value with the type `optional color`.
    */
    public static func fromOptionalEmptyColor() -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_optional_empty_color())
        return result
    }
    /**
        Creates a new setting value that is a transparent gradient.
    */
    public static func fromTransparentGradient() -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_transparent_gradient())
        return result
    }
    /**
        Creates a new setting value from the vertical gradient provided as two RGBA colors.
    */
    public static func fromVerticalGradient(_ r1: Float, _ g1: Float, _ b1: Float, _ a1: Float, _ r2: Float, _ g2: Float, _ b2: Float, _ a2: Float) -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_vertical_gradient(r1, g1, b1, a1, r2, g2, b2, a2))
        return result
    }
    /**
        Creates a new setting value from the horizontal gradient provided as two RGBA colors.
    */
    public static func fromHorizontalGradient(_ r1: Float, _ g1: Float, _ b1: Float, _ a1: Float, _ r2: Float, _ g2: Float, _ b2: Float, _ a2: Float) -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_horizontal_gradient(r1, g1, b1, a1, r2, g2, b2, a2))
        return result
    }
    /**
        Creates a new setting value from the alternating gradient provided as two RGBA colors.
    */
    public static func fromAlternatingGradient(_ r1: Float, _ g1: Float, _ b1: Float, _ a1: Float, _ r2: Float, _ g2: Float, _ b2: Float, _ a2: Float) -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_alternating_gradient(r1, g1, b1, a1, r2, g2, b2, a2))
        return result
    }
    /**
        Creates a new setting value from the alignment name provided. If it doesn't
        match a known alignment, nil is returned.
    */
    public static func fromAlignment(_ value: String) -> SettingValue? {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_alignment(value))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Creates a new setting value from the column start with name provided. If it
        doesn't match a known column start with, nil is returned.
    */
    public static func fromColumnStartWith(_ value: String) -> SettingValue? {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_column_start_with(value))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Creates a new setting value from the column update with name provided. If it
        doesn't match a known column update with, nil is returned.
    */
    public static func fromColumnUpdateWith(_ value: String) -> SettingValue? {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_column_update_with(value))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Creates a new setting value from the column update trigger. If it doesn't
        match a known column update trigger, nil is returned.
    */
    public static func fromColumnUpdateTrigger(_ value: String) -> SettingValue? {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_column_update_trigger(value))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Creates a new setting value from the layout direction. If it doesn't
        match a known layout direction, nil is returned.
    */
    public static func fromLayoutDirection(_ value: String) -> SettingValue? {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_layout_direction(value))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Creates a new setting value with the type `font`.
    */
    public static func fromFont(_ family: String, _ style: String, _ weight: String, _ stretch: String) -> SettingValue? {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_font(family, style, weight, stretch))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Creates a new empty setting value with the type `font`.
    */
    public static func fromEmptyFont() -> SettingValue {
        let result = SettingValue(ptr: LiveSplitCoreNative.SettingValue_from_empty_font())
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Shared Timer that can be used to share a single timer object with multiple
    owners.
*/
public class SharedTimerRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Creates a new shared timer handle that shares the same timer. The inner
        timer object only gets disposed when the final handle gets disposed.
    */
    public func share() -> SharedTimer {
        assert(self.ptr != Optional.none)
        let result = SharedTimer(ptr: LiveSplitCoreNative.SharedTimer_share(self.ptr))
        return result
    }
    /**
        Requests read access to the timer that is being shared. This blocks the
        thread as long as there is an active write lock. Dispose the read lock when
        you are done using the timer.
    */
    public func read() -> TimerReadLock {
        assert(self.ptr != Optional.none)
        let result = TimerReadLock(ptr: LiveSplitCoreNative.SharedTimer_read(self.ptr))
        return result
    }
    /**
        Requests write access to the timer that is being shared. This blocks the
        thread as long as there are active write or read locks. Dispose the write
        lock when you are done using the timer.
    */
    public func write() -> TimerWriteLock {
        assert(self.ptr != Optional.none)
        let result = TimerWriteLock(ptr: LiveSplitCoreNative.SharedTimer_write(self.ptr))
        return result
    }
    /**
        Replaces the timer that is being shared by the timer provided. This blocks
        the thread as long as there are active write or read locks. Everyone who is
        sharing the old timer will share the provided timer after successful
        completion.
    */
    public func replaceInner(_ timer: LSTimer) {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        LiveSplitCoreNative.SharedTimer_replace_inner(self.ptr, timer.ptr)
        timer.ptr = Optional.none
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
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    A Shared Timer that can be used to share a single timer object with multiple
    owners.
*/
public class SharedTimerRefMut: SharedTimerRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Shared Timer that can be used to share a single timer object with multiple
    owners.
*/
public class SharedTimer : SharedTimerRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.SharedTimer_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Splits Component is the main component for visualizing all the split
    times. Each segment is shown in a tabular fashion showing the segment icon,
    segment name, the delta compared to the chosen comparison, and the split
    time. The list provides scrolling functionality, so not every segment needs
    to be shown all the time.
*/
public class SplitsComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Splits Component is the main component for visualizing all the split
    times. Each segment is shown in a tabular fashion showing the segment icon,
    segment name, the delta compared to the chosen comparison, and the split
    time. The list provides scrolling functionality, so not every segment needs
    to be shown all the time.
*/
public class SplitsComponentRefMut: SplitsComponentRef {
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        assert(layoutSettings.ptr != Optional.none)
        let result = LiveSplitCoreNative.SplitsComponent_state_as_json(self.ptr, timer.ptr, layoutSettings.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state based on the timer and layout settings
        provided.
    */
    public func state(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> SplitsComponentState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        assert(layoutSettings.ptr != Optional.none)
        let result = SplitsComponentState(ptr: LiveSplitCoreNative.SplitsComponent_state(self.ptr, timer.ptr, layoutSettings.ptr))
        return result
    }
    /**
        Scrolls up the window of the segments that are shown. Doesn't move the
        scroll window if it reaches the top of the segments.
    */
    public func scrollUp() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.SplitsComponent_scroll_up(self.ptr)
    }
    /**
        Scrolls down the window of the segments that are shown. Doesn't move the
        scroll window if it reaches the bottom of the segments.
    */
    public func scrollDown() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.SplitsComponent_scroll_down(self.ptr)
    }
    /**
        The amount of segments to show in the list at any given time. If this is
        set to 0, all the segments are shown. If this is set to a number lower
        than the total amount of segments, only a certain window of all the
        segments is shown. This window can scroll up or down.
    */
    public func setVisualSplitCount(_ count: size_t) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.SplitsComponent_set_visual_split_count(self.ptr, count)
    }
    /**
        If there's more segments than segments that are shown, the window
        showing the segments automatically scrolls up and down when the current
        segment changes. This count determines the minimum number of future
        segments to be shown in this scrolling window when it automatically
        scrolls.
    */
    public func setSplitPreviewCount(_ count: size_t) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.SplitsComponent_set_split_preview_count(self.ptr, count)
    }
    /**
        If not every segment is shown in the scrolling window of segments, then
        this determines whether the final segment is always to be shown, as it
        contains valuable information about the total duration of the chosen
        comparison, which is often the runner's Personal Best.
    */
    public func setAlwaysShowLastSplit(_ alwaysShowLastSplit: Bool) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.SplitsComponent_set_always_show_last_split(self.ptr, alwaysShowLastSplit ? true : false)
    }
    /**
        If the last segment is to always be shown, this determines whether to
        show a more pronounced separator in front of the last segment, if it is
        not directly adjacent to the segment shown right before it in the
        scrolling window.
    */
    public func setSeparatorLastSplit(_ separatorLastSplit: Bool) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.SplitsComponent_set_separator_last_split(self.ptr, separatorLastSplit ? true : false)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Splits Component is the main component for visualizing all the split
    times. Each segment is shown in a tabular fashion showing the segment icon,
    segment name, the delta compared to the chosen comparison, and the split
    time. The list provides scrolling functionality, so not every segment needs
    to be shown all the time.
*/
public class SplitsComponent : SplitsComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.SplitsComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Splits Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.SplitsComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.SplitsComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object that describes a single segment's information to visualize.
*/
public class SplitsComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Describes whether a more pronounced separator should be shown in front of
        the last segment provided.
    */
    public func finalSeparatorShown() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.SplitsComponentState_final_separator_shown(self.ptr) != false
        return result
    }
    /**
        Returns the amount of segments to visualize.
    */
    public func len() -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.SplitsComponentState_len(self.ptr)
        return result
    }
    /**
        Returns the amount of icon changes that happened in this state object.
    */
    public func iconChangeCount() -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.SplitsComponentState_icon_change_count(self.ptr)
        return result
    }
    /**
        Accesses the index of the segment of the icon change with the specified
        index. This is based on the index in the run, not on the index of the
        SplitState in the State object. The corresponding index is the index field
        of the SplitState object. You may not provide an out of bounds index.
    */
    public func iconChangeSegmentIndex(_ iconChangeIndex: size_t) -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.SplitsComponentState_icon_change_segment_index(self.ptr, iconChangeIndex)
        return result
    }
    /**
        The icon data of the segment of the icon change with the specified index.
        The buffer may be empty. This indicates that there is no icon. You may not
        provide an out of bounds index.
    */
    public func iconChangeIconPtr(_ iconChangeIndex: size_t) -> UnsafeMutableRawPointer? {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.SplitsComponentState_icon_change_icon_ptr(self.ptr, iconChangeIndex)
        return result
    }
    /**
        The length of the icon data of the segment of the icon change with the
        specified index.
    */
    public func iconChangeIconLen(_ iconChangeIndex: size_t) -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.SplitsComponentState_icon_change_icon_len(self.ptr, iconChangeIndex)
        return result
    }
    /**
        The name of the segment with the specified index. You may not provide an out
        of bounds index.
    */
    public func name(_ index: size_t) -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.SplitsComponentState_name(self.ptr, index)
        return String(cString: result!)
    }
    /**
        The amount of columns to visualize for the segment with the specified index.
        The columns are specified from right to left. You may not provide an out of
        bounds index. The amount of columns to visualize may differ from segment to
        segment.
    */
    public func columnsLen(_ index: size_t) -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.SplitsComponentState_columns_len(self.ptr, index)
        return result
    }
    /**
        The column's value to show for the split and column with the specified
        index. The columns are specified from right to left. You may not provide an
        out of bounds index.
    */
    public func columnValue(_ index: size_t, _ columnIndex: size_t) -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.SplitsComponentState_column_value(self.ptr, index, columnIndex)
        return String(cString: result!)
    }
    /**
        The semantic coloring information the column's value carries of the segment
        and column with the specified index. The columns are specified from right to
        left. You may not provide an out of bounds index.
    */
    public func columnSemanticColor(_ index: size_t, _ columnIndex: size_t) -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.SplitsComponentState_column_semantic_color(self.ptr, index, columnIndex)
        return String(cString: result!)
    }
    /**
        Describes if the segment with the specified index is the segment the active
        attempt is currently on.
    */
    public func isCurrentSplit(_ index: size_t) -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.SplitsComponentState_is_current_split(self.ptr, index) != false
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The state object that describes a single segment's information to visualize.
*/
public class SplitsComponentStateRefMut: SplitsComponentStateRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object that describes a single segment's information to visualize.
*/
public class SplitsComponentState : SplitsComponentStateRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.SplitsComponentState_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Sum of Best Cleaner allows you to interactively remove potential issues in
    the Segment History that lead to an inaccurate Sum of Best. If you skip a
    split, whenever you get to the next split, the combined segment time might
    be faster than the sum of the individual best segments. The Sum of Best
    Cleaner will point out all of occurrences of this and allows you to delete
    them individually if any of them seem wrong.
*/
public class SumOfBestCleanerRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    A Sum of Best Cleaner allows you to interactively remove potential issues in
    the Segment History that lead to an inaccurate Sum of Best. If you skip a
    split, whenever you get to the next split, the combined segment time might
    be faster than the sum of the individual best segments. The Sum of Best
    Cleaner will point out all of occurrences of this and allows you to delete
    them individually if any of them seem wrong.
*/
public class SumOfBestCleanerRefMut: SumOfBestCleanerRef {
    /**
        Returns the next potential clean up. If there are no more potential
        clean ups, nil is returned.
    */
    public func nextPotentialCleanUp() -> PotentialCleanUp? {
        assert(self.ptr != Optional.none)
        let result = PotentialCleanUp(ptr: LiveSplitCoreNative.SumOfBestCleaner_next_potential_clean_up(self.ptr))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Applies a clean up to the Run.
    */
    public func apply(_ cleanUp: PotentialCleanUp) {
        assert(self.ptr != Optional.none)
        assert(cleanUp.ptr != Optional.none)
        LiveSplitCoreNative.SumOfBestCleaner_apply(self.ptr, cleanUp.ptr)
        cleanUp.ptr = Optional.none
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Sum of Best Cleaner allows you to interactively remove potential issues in
    the Segment History that lead to an inaccurate Sum of Best. If you skip a
    split, whenever you get to the next split, the combined segment time might
    be faster than the sum of the individual best segments. The Sum of Best
    Cleaner will point out all of occurrences of this and allows you to delete
    them individually if any of them seem wrong.
*/
public class SumOfBestCleaner : SumOfBestCleanerRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.SumOfBestCleaner_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Sum of Best Segments Component shows the fastest possible time to
    complete a run of this category, based on information collected from all the
    previous attempts. This often matches up with the sum of the best segment
    times of all the segments, but that may not always be the case, as skipped
    segments may introduce combined segments that may be faster than the actual
    sum of their best segment times. The name is therefore a bit misleading, but
    sticks around for historical reasons.
*/
public class SumOfBestComponentRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = LiveSplitCoreNative.SumOfBestComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state based on the timer provided.
    */
    public func state(_ timer: TimerRef) -> KeyValueComponentState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = KeyValueComponentState(ptr: LiveSplitCoreNative.SumOfBestComponent_state(self.ptr, timer.ptr))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Sum of Best Segments Component shows the fastest possible time to
    complete a run of this category, based on information collected from all the
    previous attempts. This often matches up with the sum of the best segment
    times of all the segments, but that may not always be the case, as skipped
    segments may introduce combined segments that may be faster than the actual
    sum of their best segment times. The name is therefore a bit misleading, but
    sticks around for historical reasons.
*/
public class SumOfBestComponentRefMut: SumOfBestComponentRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Sum of Best Segments Component shows the fastest possible time to
    complete a run of this category, based on information collected from all the
    previous attempts. This often matches up with the sum of the best segment
    times of all the segments, but that may not always be the case, as skipped
    segments may introduce combined segments that may be faster than the actual
    sum of their best segment times. The name is therefore a bit misleading, but
    sticks around for historical reasons.
*/
public class SumOfBestComponent : SumOfBestComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.SumOfBestComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Sum of Best Segments Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.SumOfBestComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.SumOfBestComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Text Component simply visualizes any given text. This can either be a
    single centered text, or split up into a left and right text, which is
    suitable for a situation where you have a label and a value.
*/
public class TextComponentRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = LiveSplitCoreNative.TextComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state.
    */
    public func state(_ timer: TimerRef) -> TextComponentState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = TextComponentState(ptr: LiveSplitCoreNative.TextComponent_state(self.ptr, timer.ptr))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Text Component simply visualizes any given text. This can either be a
    single centered text, or split up into a left and right text, which is
    suitable for a situation where you have a label and a value.
*/
public class TextComponentRefMut: TextComponentRef {
    /**
        Sets the centered text. If the current mode is split, it is switched to
        centered mode.
    */
    public func setCenter(_ text: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.TextComponent_set_center(self.ptr, text)
    }
    /**
        Sets the left text. If the current mode is centered, it is switched to
        split mode, with the right text being empty.
    */
    public func setLeft(_ text: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.TextComponent_set_left(self.ptr, text)
    }
    /**
        Sets the right text. If the current mode is centered, it is switched to
        split mode, with the left text being empty.
    */
    public func setRight(_ text: String) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.TextComponent_set_right(self.ptr, text)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Text Component simply visualizes any given text. This can either be a
    single centered text, or split up into a left and right text, which is
    suitable for a situation where you have a label and a value.
*/
public class TextComponent : TextComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.TextComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Text Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.TextComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.TextComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class TextComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Accesses the left part of the text. If the text isn't split up, an empty
        string is returned instead.
    */
    public func left() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TextComponentState_left(self.ptr)
        return String(cString: result!)
    }
    /**
        Accesses the right part of the text. If the text isn't split up, an empty
        string is returned instead.
    */
    public func right() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TextComponentState_right(self.ptr)
        return String(cString: result!)
    }
    /**
        Accesses the centered text. If the text isn't centered, an empty string is
        returned instead.
    */
    public func center() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TextComponentState_center(self.ptr)
        return String(cString: result!)
    }
    /**
        Returns whether the text is split up into a left and right part.
    */
    public func isSplit() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TextComponentState_is_split(self.ptr) != false
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class TextComponentStateRefMut: TextComponentStateRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class TextComponentState : TextComponentStateRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.TextComponentState_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A time that can store a Real Time and a Game Time. Both of them are
    optional.
*/
public class TimeRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Clones the time.
    */
    public func clone() -> Time {
        assert(self.ptr != Optional.none)
        let result = Time(ptr: LiveSplitCoreNative.Time_clone(self.ptr))
        return result
    }
    /**
        The Real Time value. This may be nil if this time has no Real Time value.
    */
    public func realTime() -> TimeSpanRef? {
        assert(self.ptr != Optional.none)
        let result = TimeSpanRef(ptr: LiveSplitCoreNative.Time_real_time(self.ptr))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        The Game Time value. This may be nil if this time has no Game Time value.
    */
    public func gameTime() -> TimeSpanRef? {
        assert(self.ptr != Optional.none)
        let result = TimeSpanRef(ptr: LiveSplitCoreNative.Time_game_time(self.ptr))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Access the time's value for the timing method specified.
    */
    public func index(_ timingMethod: UInt8) -> TimeSpanRef? {
        assert(self.ptr != Optional.none)
        let result = TimeSpanRef(ptr: LiveSplitCoreNative.Time_index(self.ptr, timingMethod))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    A time that can store a Real Time and a Game Time. Both of them are
    optional.
*/
public class TimeRefMut: TimeRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A time that can store a Real Time and a Game Time. Both of them are
    optional.
*/
public class Time : TimeRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.Time_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Time Span represents a certain span of time.
*/
public class TimeSpanRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Clones the Time Span.
    */
    public func clone() -> TimeSpan {
        assert(self.ptr != Optional.none)
        let result = TimeSpan(ptr: LiveSplitCoreNative.TimeSpan_clone(self.ptr))
        return result
    }
    /**
        Returns the total amount of seconds (including decimals) this Time Span
        represents.
    */
    public func totalSeconds() -> Double {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TimeSpan_total_seconds(self.ptr)
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    A Time Span represents a certain span of time.
*/
public class TimeSpanRefMut: TimeSpanRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Time Span represents a certain span of time.
*/
public class TimeSpan : TimeSpanRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.TimeSpan_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Time Span from a given amount of seconds.
    */
    public static func fromSeconds(_ seconds: Double) -> TimeSpan {
        let result = TimeSpan(ptr: LiveSplitCoreNative.TimeSpan_from_seconds(seconds))
        return result
    }
    /**
        Parses a Time Span from a string. Returns nil if the time can't be
        parsed.
    */
    public static func parse(_ text: String) -> TimeSpan? {
        let result = TimeSpan(ptr: LiveSplitCoreNative.TimeSpan_parse(text))
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Timer provides all the capabilities necessary for doing speedrun attempts.
*/
public class TimerRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Returns the currently selected Timing Method.
    */
    public func currentTimingMethod() -> UInt8 {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Timer_current_timing_method(self.ptr)
        return result
    }
    /**
        Returns the current comparison that is being compared against. This may
        be a custom comparison or one of the Comparison Generators.
    */
    public func currentComparison() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Timer_current_comparison(self.ptr)
        return String(cString: result!)
    }
    /**
        Returns whether Game Time is currently initialized. Game Time
        automatically gets uninitialized for each new attempt.
    */
    public func isGameTimeInitialized() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Timer_is_game_time_initialized(self.ptr) != false
        return result
    }
    /**
        Returns whether the Game Timer is currently paused. If the Game Timer is
        not paused, it automatically increments similar to Real Time.
    */
    public func isGameTimePaused() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Timer_is_game_time_paused(self.ptr) != false
        return result
    }
    /**
        Accesses the loading times. Loading times are defined as Game Time - Real Time.
    */
    public func loadingTimes() -> TimeSpanRef {
        assert(self.ptr != Optional.none)
        let result = TimeSpanRef(ptr: LiveSplitCoreNative.Timer_loading_times(self.ptr))
        return result
    }
    /**
        Returns the current Timer Phase.
    */
    public func currentPhase() -> UInt8 {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Timer_current_phase(self.ptr)
        return result
    }
    /**
        Accesses the Run in use by the Timer.
    */
    public func getRun() -> RunRef {
        assert(self.ptr != Optional.none)
        let result = RunRef(ptr: LiveSplitCoreNative.Timer_get_run(self.ptr))
        return result
    }
    /**
        Saves the Run in use by the Timer as a LiveSplit splits file (*.lss).
    */
    public func saveAsLss() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.Timer_save_as_lss(self.ptr)
        return String(cString: result!)
    }
    /**
        Prints out debug information representing the whole state of the Timer. This
        is being written to stdout.
    */
    public func printDebug() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_print_debug(self.ptr)
    }
    /**
        Returns the current time of the Timer. The Game Time is nil if the Game
        Time has not been initialized.
    */
    public func currentTime() -> TimeRef {
        assert(self.ptr != Optional.none)
        let result = TimeRef(ptr: LiveSplitCoreNative.Timer_current_time(self.ptr))
        return result
    }
	
	/**
		Accesses the index of the split the attempt is currently on. If there's
		no attempt in progress, `None` is returned instead. This returns an
		index that is equal to the amount of segments when the attempt is
		finished, but has not been reset. So you need to be careful when using
		this value for indexing.
	*/
	public func currentSegmentIndex() -> Int64 {
		assert(self.ptr != Optional.none)
		let result = LiveSplitCoreNative.Timer_current_split_index(self.ptr)
		return result
	}
	
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    A Timer provides all the capabilities necessary for doing speedrun attempts.
*/
public class TimerRefMut: TimerRef {
    /**
        Replaces the Run object used by the Timer with the Run object provided. If
        the Run provided contains no segments, it can't be used for timing and is
        not being modified. Otherwise the Run that was in use by the Timer gets
        stored in the Run object provided. Before the Run is returned, the current
        attempt is reset and the splits are being updated depending on the
        `update_splits` parameter. The return value indicates whether the Run got
        replaced successfully.
    */
    public func replaceRun(_ run: RunRefMut, _ updateSplits: Bool) -> Bool {
        assert(self.ptr != Optional.none)
        assert(run.ptr != Optional.none)
        let result = LiveSplitCoreNative.Timer_replace_run(self.ptr, run.ptr, updateSplits ? true : false) != false
        return result
    }
    /**
        Sets the Run object used by the Timer with the Run object provided. If the
        Run provided contains no segments, it can't be used for timing and gets
        returned again. If the Run object can be set, the original Run object in use
        by the Timer is disposed by this method and nil is returned.
    */
    public func setRun(_ run: Run) -> Run? {
        assert(self.ptr != Optional.none)
        assert(run.ptr != Optional.none)
        let result = Run(ptr: LiveSplitCoreNative.Timer_set_run(self.ptr, run.ptr))
        run.ptr = Optional.none
        if result.ptr == Optional.none {
            return Optional.none
        }
        return result
    }
    /**
        Starts the Timer if there is no attempt in progress. If that's not the
        case, nothing happens.
    */
    public func start() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_start(self.ptr)
    }
    /**
        If an attempt is in progress, stores the current time as the time of the
        current split. The attempt ends if the last split time is stored.
    */
    public func split() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_split(self.ptr)
    }
    /**
        Starts a new attempt or stores the current time as the time of the
        current split. The attempt ends if the last split time is stored.
    */
    public func splitOrStart() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_split_or_start(self.ptr)
    }
    /**
        Skips the current split if an attempt is in progress and the
        current split is not the last split.
    */
    public func skipSplit() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_skip_split(self.ptr)
    }
    /**
        Removes the split time from the last split if an attempt is in progress
        and there is a previous split. The Timer Phase also switches to
        `Running` if it previously was `Ended`.
    */
    public func undoSplit() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_undo_split(self.ptr)
    }
    /**
        Resets the current attempt if there is one in progress. If the splits
        are to be updated, all the information of the current attempt is stored
        in the Run's history. Otherwise the current attempt's information is
        discarded.
    */
    public func reset(_ updateSplits: Bool) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_reset(self.ptr, updateSplits ? true : false)
    }
    /**
        Resets the current attempt if there is one in progress. The splits are
        updated such that the current attempt's split times are being stored as
        the new Personal Best.
    */
    public func resetAndSetAttemptAsPb() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_reset_and_set_attempt_as_pb(self.ptr)
    }
    /**
        Pauses an active attempt that is not paused.
    */
    public func pause() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_pause(self.ptr)
    }
    /**
        Resumes an attempt that is paused.
    */
    public func resume() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_resume(self.ptr)
    }
    /**
        Toggles an active attempt between `Paused` and `Running`.
    */
    public func togglePause() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_toggle_pause(self.ptr)
    }
    /**
        Toggles an active attempt between `Paused` and `Running` or starts an
        attempt if there's none in progress.
    */
    public func togglePauseOrStart() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_toggle_pause_or_start(self.ptr)
    }
    /**
        Removes all the pause times from the current time. If the current
        attempt is paused, it also resumes that attempt. Additionally, if the
        attempt is finished, the final split time is adjusted to not include the
        pause times as well.
        
        # Warning
        
        This behavior is not entirely optimal, as generally only the final split
        time is modified, while all other split times are left unmodified, which
        may not be what actually happened during the run.
    */
    public func undoAllPauses() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_undo_all_pauses(self.ptr)
    }
    /**
        Sets the current Timing Method to the Timing Method provided.
    */
    public func setCurrentTimingMethod(_ method: UInt8) {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_set_current_timing_method(self.ptr, method)
    }
    /**
        Switches the current comparison to the next comparison in the list.
    */
    public func switchToNextComparison() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_switch_to_next_comparison(self.ptr)
    }
    /**
        Switches the current comparison to the previous comparison in the list.
    */
    public func switchToPreviousComparison() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_switch_to_previous_comparison(self.ptr)
    }
    /**
        Initializes Game Time for the current attempt. Game Time automatically
        gets uninitialized for each new attempt.
    */
    public func initializeGameTime() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_initialize_game_time(self.ptr)
    }
    /**
        Deinitializes Game Time for the current attempt.
    */
    public func deinitializeGameTime() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_deinitialize_game_time(self.ptr)
    }
    /**
        Pauses the Game Timer such that it doesn't automatically increment
        similar to Real Time.
    */
    public func pauseGameTime() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_pause_game_time(self.ptr)
    }
    /**
        Resumes the Game Timer such that it automatically increments similar to
        Real Time, starting from the Game Time it was paused at.
    */
    public func resumeGameTime() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_resume_game_time(self.ptr)
    }
    /**
        Sets the Game Time to the time specified. This also works if the Game
        Time is paused, which can be used as a way of updating the Game Timer
        periodically without it automatically moving forward. This ensures that
        the Game Timer never shows any time that is not coming from the game.
    */
    public func setGameTime(_ time: TimeSpanRef) {
        assert(self.ptr != Optional.none)
        assert(time.ptr != Optional.none)
        LiveSplitCoreNative.Timer_set_game_time(self.ptr, time.ptr)
    }
    /**
        Instead of setting the Game Time directly, this method can be used to
        just specify the amount of time the game has been loading. The Game Time
        is then automatically determined by Real Time - Loading Times.
    */
    public func setLoadingTimes(_ time: TimeSpanRef) {
        assert(self.ptr != Optional.none)
        assert(time.ptr != Optional.none)
        LiveSplitCoreNative.Timer_set_loading_times(self.ptr, time.ptr)
    }
    /**
        Marks the Run as unmodified, so that it is known that all the changes
        have been saved.
    */
    public func markAsUnmodified() {
        assert(self.ptr != Optional.none)
        LiveSplitCoreNative.Timer_mark_as_unmodified(self.ptr)
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Timer provides all the capabilities necessary for doing speedrun attempts.
*/
public class LSTimer : TimerRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.Timer_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Timer based on a Run object storing all the information
        about the splits. The Run object needs to have at least one segment, so
        that the Timer can store the final time. If a Run object with no
        segments is provided, the Timer creation fails and nil is returned.
    */
    public init?(_ run: Run) {
        super.init(ptr: Optional.none)
        assert(run.ptr != Optional.none)
        let result = LiveSplitCoreNative.Timer_new(run.ptr)
        run.ptr = Optional.none
        if result == Optional.none {
            return nil
        }
        self.ptr = result
    }
    /**
        Consumes the Timer and creates a Shared Timer that can be shared across
        multiple threads with multiple owners.
    */
    public func intoShared() -> SharedTimer {
        assert(self.ptr != Optional.none)
        let result = SharedTimer(ptr: LiveSplitCoreNative.Timer_into_shared(self.ptr))
        self.ptr = Optional.none
        return result
    }
    /**
        Takes out the Run from the Timer and resets the current attempt if there
        is one in progress. If the splits are to be updated, all the information
        of the current attempt is stored in the Run's history. Otherwise the
        current attempt's information is discarded.
    */
    public func intoRun(_ updateSplits: Bool) -> Run {
        assert(self.ptr != Optional.none)
        let result = Run(ptr: LiveSplitCoreNative.Timer_into_run(self.ptr, updateSplits ? true : false))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Timer Component is a component that shows the total time of the current
    attempt as a digital clock. The color of the time shown is based on a how
    well the current attempt is doing compared to the chosen comparison.
*/
public class TimerComponentRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        assert(layoutSettings.ptr != Optional.none)
        let result = LiveSplitCoreNative.TimerComponent_state_as_json(self.ptr, timer.ptr, layoutSettings.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state based on the timer and the layout
        settings provided.
    */
    public func state(_ timer: TimerRef, _ layoutSettings: GeneralLayoutSettingsRef) -> TimerComponentState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        assert(layoutSettings.ptr != Optional.none)
        let result = TimerComponentState(ptr: LiveSplitCoreNative.TimerComponent_state(self.ptr, timer.ptr, layoutSettings.ptr))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Timer Component is a component that shows the total time of the current
    attempt as a digital clock. The color of the time shown is based on a how
    well the current attempt is doing compared to the chosen comparison.
*/
public class TimerComponentRefMut: TimerComponentRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Timer Component is a component that shows the total time of the current
    attempt as a digital clock. The color of the time shown is based on a how
    well the current attempt is doing compared to the chosen comparison.
*/
public class TimerComponent : TimerComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.TimerComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Timer Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.TimerComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.TimerComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class TimerComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        The time shown by the component without the fractional part.
    */
    public func time() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TimerComponentState_time(self.ptr)
        return String(cString: result!)
    }
    /**
        The fractional part of the time shown (including the dot).
    */
    public func fraction() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TimerComponentState_fraction(self.ptr)
        return String(cString: result!)
    }
    /**
        The semantic coloring information the time carries.
    */
    public func semanticColor() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TimerComponentState_semantic_color(self.ptr)
        return String(cString: result!)
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class TimerComponentStateRefMut: TimerComponentStateRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class TimerComponentState : TimerComponentStateRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.TimerComponentState_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Timer Read Lock allows temporary read access to a timer. Dispose this to
    release the read lock.
*/
public class TimerReadLockRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        Accesses the timer.
    */
    public func timer() -> TimerRef {
        assert(self.ptr != Optional.none)
        let result = TimerRef(ptr: LiveSplitCoreNative.TimerReadLock_timer(self.ptr))
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    A Timer Read Lock allows temporary read access to a timer. Dispose this to
    release the read lock.
*/
public class TimerReadLockRefMut: TimerReadLockRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Timer Read Lock allows temporary read access to a timer. Dispose this to
    release the read lock.
*/
public class TimerReadLock : TimerReadLockRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.TimerReadLock_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Timer Write Lock allows temporary write access to a timer. Dispose this to
    release the write lock.
*/
public class TimerWriteLockRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    A Timer Write Lock allows temporary write access to a timer. Dispose this to
    release the write lock.
*/
public class TimerWriteLockRefMut: TimerWriteLockRef {
    /**
        Accesses the timer.
    */
    public func timer() -> TimerRefMut {
        assert(self.ptr != Optional.none)
        let result = TimerRefMut(ptr: LiveSplitCoreNative.TimerWriteLock_timer(self.ptr))
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    A Timer Write Lock allows temporary write access to a timer. Dispose this to
    release the write lock.
*/
public class TimerWriteLock : TimerWriteLockRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.TimerWriteLock_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Title Component is a component that shows the name of the game and the
    category that is being run. Additionally, the game icon, the attempt count,
    and the total number of successfully finished runs can be shown.
*/
public class TitleComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Title Component is a component that shows the name of the game and the
    category that is being run. Additionally, the game icon, the attempt count,
    and the total number of successfully finished runs can be shown.
*/
public class TitleComponentRefMut: TitleComponentRef {
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = LiveSplitCoreNative.TitleComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state based on the timer provided.
    */
    public func state(_ timer: TimerRef) -> TitleComponentState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = TitleComponentState(ptr: LiveSplitCoreNative.TitleComponent_state(self.ptr, timer.ptr))
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Title Component is a component that shows the name of the game and the
    category that is being run. Additionally, the game icon, the attempt count,
    and the total number of successfully finished runs can be shown.
*/
public class TitleComponent : TitleComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.TitleComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Title Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.TitleComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.TitleComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class TitleComponentStateRef {
    var ptr: UnsafeMutableRawPointer?
    /**
        The data of the game's icon. This value is only specified whenever the icon
        changes. If you explicitly want to query this value, remount the component.
        The buffer may be empty. This indicates that there is no icon. If no change
        occurred, nil is returned instead.
    */
    public func iconChangePtr() -> UnsafeMutableRawPointer? {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TitleComponentState_icon_change_ptr(self.ptr)
        return result
    }
    /**
        The length of the game's icon data.
    */
    public func iconChangeLen() -> size_t {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TitleComponentState_icon_change_len(self.ptr)
        return result
    }
    /**
        The first title line to show. This is either the game's name, or a
        combination of the game's name and the category.
    */
    public func line1() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TitleComponentState_line1(self.ptr)
        return String(cString: result!)
    }
    /**
        By default the category name is shown on the second line. Based on the
        settings, it can however instead be shown in a single line together with
        the game name. In that case nil is returned instead.
    */
    public func line2() -> String {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TitleComponentState_line2(self.ptr)
        return String(cString: result!)
    }
    /**
        Specifies whether the title should centered or aligned to the left
        instead.
    */
    public func isCentered() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TitleComponentState_is_centered(self.ptr) != false
        return result
    }
    /**
        Returns whether the amount of successfully finished attempts is supposed to
        be shown.
    */
    public func showsFinishedRuns() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TitleComponentState_shows_finished_runs(self.ptr) != false
        return result
    }
    /**
        Returns the amount of successfully finished attempts.
    */
    public func finishedRuns() -> UInt32 {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TitleComponentState_finished_runs(self.ptr)
        return result
    }
    /**
        Returns whether the amount of total attempts is supposed to be shown.
    */
    public func showsAttempts() -> Bool {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TitleComponentState_shows_attempts(self.ptr) != false
        return result
    }
    /**
        Returns the amount of total attempts.
    */
    public func attempts() -> UInt32 {
        assert(self.ptr != Optional.none)
        let result = LiveSplitCoreNative.TitleComponentState_attempts(self.ptr)
        return result
    }
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class TitleComponentStateRefMut: TitleComponentStateRef {
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The state object describes the information to visualize for this component.
*/
public class TitleComponentState : TitleComponentStateRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.TitleComponentState_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Total Playtime Component is a component that shows the total amount of
    time that the current category has been played for.
*/
public class TotalPlaytimeComponentRef {
    var ptr: UnsafeMutableRawPointer?
    init(ptr: UnsafeMutableRawPointer?) {
        self.ptr = ptr
    }
}

/**
    The Total Playtime Component is a component that shows the total amount of
    time that the current category has been played for.
*/
public class TotalPlaytimeComponentRefMut: TotalPlaytimeComponentRef {
    /**
        Encodes the component's state information as JSON.
    */
    public func stateAsJson(_ timer: TimerRef) -> String {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = LiveSplitCoreNative.TotalPlaytimeComponent_state_as_json(self.ptr, timer.ptr)
        return String(cString: result!)
    }
    /**
        Calculates the component's state based on the timer provided.
    */
    public func state(_ timer: TimerRef) -> KeyValueComponentState {
        assert(self.ptr != Optional.none)
        assert(timer.ptr != Optional.none)
        let result = KeyValueComponentState(ptr: LiveSplitCoreNative.TotalPlaytimeComponent_state(self.ptr, timer.ptr))
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

/**
    The Total Playtime Component is a component that shows the total amount of
    time that the current category has been played for.
*/
public class TotalPlaytimeComponent : TotalPlaytimeComponentRefMut {
    private func drop() {
        if self.ptr != Optional.none {
            LiveSplitCoreNative.TotalPlaytimeComponent_drop(self.ptr)
            self.ptr = Optional.none
        }
    }
    deinit {
        self.drop()
    }
    public func dispose() {
        self.drop()
    }
    /**
        Creates a new Total Playtime Component.
    */
    public init() {
        super.init(ptr: Optional.none)
        let result = LiveSplitCoreNative.TotalPlaytimeComponent_new()
        self.ptr = result
    }
    /**
        Converts the component into a generic component suitable for using with a
        layout.
    */
    public func intoGeneric() -> Component {
        assert(self.ptr != Optional.none)
        let result = Component(ptr: LiveSplitCoreNative.TotalPlaytimeComponent_into_generic(self.ptr))
        self.ptr = Optional.none
        return result
    }
    override init(ptr: UnsafeMutableRawPointer?) {
        super.init(ptr: ptr)
    }
}

typealias LSCColumn = (index: Int, name: String, updateWith: ColumnUpdateWith, startWith: ColumnStartWith, updateFrom: ColumnUpdateWith, comparison: String?, timingMethod: TimingMethod)
extension LayoutEditor {
	/// - NOTE: Must have splits as the currently selected segment
	
	func settingsStartIndex(for column: Int) -> Int {
		let value = 11 + (column * 6)
		return value
	}
	func setNumberOfColumns(_ index: Int, count: Int) {
		self.setComponentSettingsValue(10, .fromInt(Int32(count)))
	}
	
	func setColumn(_ index: Int, name: String) {
		let settingIndex = settingsStartIndex(for: index)
		self.setComponentSettingsValue(settingIndex, .fromString(name))
	}
	func setColumn(_ index: Int, startWith: ColumnStartWith) {
		let settingIndex = settingsStartIndex(for: index) + 1
		if let startWith = SettingValue.fromColumnStartWith(startWith.rawValue) {
			self.setComponentSettingsValue(settingIndex, startWith)
		}
	}
	func setColumn(_ index: Int, updateWith: ColumnUpdateWith) {
		let settingIndex = settingsStartIndex(for: index) + 2
		if let setting = SettingValue.fromColumnUpdateWith(updateWith.rawValue) {
			self.setComponentSettingsValue(settingIndex, SettingValue.fromColumnUpdateWith("DontUpdate")!)
		}
	}
	func setColumn(_ index: Int, updateTrigger: ColumnUpdateTrigger) {
		let settingIndex = settingsStartIndex(for: index) + 3
		if let updateTrigger = SettingValue.fromColumnUpdateWith(updateTrigger.rawValue) {
			self.setComponentSettingsValue(settingIndex, updateTrigger)
		}
	}
	func setColumn(_ index: Int, comparison: String?) {
		let settingIndex = settingsStartIndex(for: index) + 4
		if let comparison = comparison {
			let set = SettingValue.fromOptionalString(comparison)
			self.setComponentSettingsValue(settingIndex, SettingValue.fromOptionalString(comparison))
		}
	}
	func setColumn(_ index: Int, timingMethod: TimingMethod) {
		let settingIndex = settingsStartIndex(for: index) + 5
		if let timingMethod = SettingValue.fromOptionalTimingMethod(timingMethod.rawValue) {
			self.setComponentSettingsValue(settingIndex, timingMethod)
		}
	}
}


enum TimingMethod: String {
	case gameTime = "GameTime"
	case realTime = "RealTime"
}
///Specifies the value a segment starts out with before it gets replaced with the current attempt's information when splitting.
enum ColumnStartWith: String {
	///The column starts out with an empty value.
	case empty = "Empty"
	///The column starts out with the times stored in the comparison that is being compared against.
	case comparisonTime = "ComparisonTime"
	///The column starts out with the segment times stored in the comparison that is being compared against.
	case comparsionSegmentTime = "ComparisonSegmentTime"
	///The column starts out with the time that can be saved on each individual segment stored in the comparison that is being compared against.
	case possibleTimeSave = "PossibleTimeSave"
}
///Once a certain condition is met, which is usually being on the split or already having completed the split, the time gets updated with the value specified here.
enum ColumnUpdateWith: String {
	///The value doesn't get updated and stays on the value it started out with
	case dontUpdate = "DontUpdate"
	
	///The value gets replaced by the current attempt's split time.
	case splitTime = "SplitTime"
	///Delta between the split time of the current attempt and the current comparison
	///
	///The value gets replaced by the delta of the current attempt's and the comparison's split time.
	case delta = "Delta"
	
	///Delta, but shows the current Split Time if there isn't a delta
	///
	///The value gets replaced by the delta of the current attempt's and the comparison's split time. If there is no delta, the value gets replaced by the current attempt's split time instead.
	case deltaWithFallback = "DeltaWithFallback"
	
	///The value gets replaced by the current attempt's segment time.
	case segmentTime = "SegmentTime"
	
	///The value gets replaced by the current attempt's time saved or lost, which is how much faster or slower the current attempt's segment time is compared to the comparison's segment time. This matches the Previous Segment component.
	case segmentDelta = "SegmentDelta"
	///The value gets replaced by the current attempt's time saved or lost, which is how much faster or slower the current attempt's segment time is compared to the comparison's segment time. This matches the Previous Segment component. If there is no time saved or lost, then value gets replaced by the current attempt's segment time instead.
	case segmentDeltaWithFallback = "SegmentDeltaWithFallback"

}
///Specifies when a column's value gets updated.
enum ColumnUpdateTrigger: String {
	//"When segment begins"
	///The value gets updated as soon as the segment is started. The value constantly updates until the segment ends.
	case onStartingSegment = "OnStartingSegment"
	
	//"After longer than comparison"?
	///The value doesn't immediately get updated when the segment is started. Instead the value constantly gets updated once the segment time is longer than the best segment time. The final update to the value happens when the segment ends.
	case contextual = "Contextual"
	
	//"When segment ends"
	///The value of a segment gets updated once the segment ends.
	case onEndingSegment = "OnEndingSegment"
}

private struct DecodedSettingsValue: Codable {
	
	var int: Int?
	
	enum CodingKeys: String, CodingKey {
		case int = "UInt"
	}
	
	init(from decoder: Decoder) throws {
		let c = try decoder.container(keyedBy: CodingKeys.self)
		int = try c.decodeIfPresent(Int.self, forKey: .int)
	}
}
