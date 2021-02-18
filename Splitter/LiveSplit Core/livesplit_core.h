#ifndef LIVESPLIT_CORE_H
#define LIVESPLIT_CORE_H

#ifdef __cplusplus
namespace LiveSplit {
extern "C" {
#endif

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

void* Analysis_calculate_sum_of_best(void* run, bool simple_calculation, bool use_current_run, uint8_t method);
void* Analysis_calculate_total_playtime_for_run(void* run);
void* Analysis_calculate_total_playtime_for_timer(void* timer);

void AtomicDateTime_drop(void* self);
bool AtomicDateTime_is_synchronized(void* self);
char const* AtomicDateTime_to_rfc2822(void* self);
char const* AtomicDateTime_to_rfc3339(void* self);

int32_t Attempt_index(void* self);
void* Attempt_time(void* self);
void* Attempt_pause_time(void* self);
void* Attempt_started(void* self);
void* Attempt_ended(void* self);

void* BlankSpaceComponent_new(void);
void BlankSpaceComponent_drop(void* self);
void* BlankSpaceComponent_into_generic(void* self);
char const* BlankSpaceComponent_state_as_json(void* self);
void* BlankSpaceComponent_state(void* self);

void BlankSpaceComponentState_drop(void* self);
uint32_t BlankSpaceComponentState_size(void* self);

void Component_drop(void* self);

void* CurrentComparisonComponent_new(void);
void CurrentComparisonComponent_drop(void* self);
void* CurrentComparisonComponent_into_generic(void* self);
char const* CurrentComparisonComponent_state_as_json(void* self, void* timer);
void* CurrentComparisonComponent_state(void* self, void* timer);

void* CurrentPaceComponent_new(void);
void CurrentPaceComponent_drop(void* self);
void* CurrentPaceComponent_into_generic(void* self);
char const* CurrentPaceComponent_state_as_json(void* self, void* timer);
void* CurrentPaceComponent_state(void* self, void* timer);

void* DeltaComponent_new(void);
void DeltaComponent_drop(void* self);
void* DeltaComponent_into_generic(void* self);
char const* DeltaComponent_state_as_json(void* self, void* timer, void* layout_settings);
void* DeltaComponent_state(void* self, void* timer, void* layout_settings);

void* DetailedTimerComponent_new(void);
void DetailedTimerComponent_drop(void* self);
void* DetailedTimerComponent_into_generic(void* self);
char const* DetailedTimerComponent_state_as_json(void* self, void* timer, void* layout_settings);
void* DetailedTimerComponent_state(void* self, void* timer, void* layout_settings);

void DetailedTimerComponentState_drop(void* self);
char const* DetailedTimerComponentState_timer_time(void* self);
char const* DetailedTimerComponentState_timer_fraction(void* self);
char const* DetailedTimerComponentState_timer_semantic_color(void* self);
char const* DetailedTimerComponentState_segment_timer_time(void* self);
char const* DetailedTimerComponentState_segment_timer_fraction(void* self);
bool DetailedTimerComponentState_comparison1_visible(void* self);
char const* DetailedTimerComponentState_comparison1_name(void* self);
char const* DetailedTimerComponentState_comparison1_time(void* self);
bool DetailedTimerComponentState_comparison2_visible(void* self);
char const* DetailedTimerComponentState_comparison2_name(void* self);
char const* DetailedTimerComponentState_comparison2_time(void* self);
void* DetailedTimerComponentState_icon_change_ptr(void* self);
size_t DetailedTimerComponentState_icon_change_len(void* self);
char const* DetailedTimerComponentState_segment_name(void* self);

void* FuzzyList_new(void);
void FuzzyList_drop(void* self);
char const* FuzzyList_search(void* self, char const* pattern, size_t max);
void FuzzyList_push(void* self, char const* text);

void* GeneralLayoutSettings_default(void);
void GeneralLayoutSettings_drop(void* self);

void* GraphComponent_new(void);
void GraphComponent_drop(void* self);
void* GraphComponent_into_generic(void* self);
char const* GraphComponent_state_as_json(void* self, void* timer, void* layout_settings);
void* GraphComponent_state(void* self, void* timer, void* layout_settings);

void GraphComponentState_drop(void* self);
size_t GraphComponentState_points_len(void* self);
float GraphComponentState_point_x(void* self, size_t index);
float GraphComponentState_point_y(void* self, size_t index);
bool GraphComponentState_point_is_best_segment(void* self, size_t index);
size_t GraphComponentState_horizontal_grid_lines_len(void* self);
float GraphComponentState_horizontal_grid_line(void* self, size_t index);
size_t GraphComponentState_vertical_grid_lines_len(void* self);
float GraphComponentState_vertical_grid_line(void* self, size_t index);
float GraphComponentState_middle(void* self);
bool GraphComponentState_is_live_delta_active(void* self);
bool GraphComponentState_is_flipped(void* self);

void* HotkeyConfig_new(void);
void* HotkeyConfig_parse_json(char const* settings);
void* HotkeyConfig_parse_file_handle(int64_t handle);
void HotkeyConfig_drop(void* self);
char const* HotkeyConfig_settings_description_as_json(void* self);
char const* HotkeyConfig_as_json(void* self);
bool HotkeyConfig_set_value(void* self, size_t index, void* value);

void* HotkeySystem_new(void* shared_timer);
void* HotkeySystem_with_config(void* shared_timer, void* config);
void HotkeySystem_drop(void* self);
void* HotkeySystem_config(void* self);
bool HotkeySystem_deactivate(void* self);
bool HotkeySystem_activate(void* self);
bool HotkeySystem_set_config(void* self, void* config);

void KeyValueComponentState_drop(void* self);
char const* KeyValueComponentState_key(void* self);
char const* KeyValueComponentState_value(void* self);
char const* KeyValueComponentState_semantic_color(void* self);

void* Layout_new(void);
void* Layout_default_layout(void);
void* Layout_parse_json(char const* settings);
void* Layout_parse_file_handle(int64_t handle);
void* Layout_parse_original_livesplit(void* data, size_t length);
void Layout_drop(void* self);
void* Layout_clone(void* self);
char const* Layout_settings_as_json(void* self);
void* Layout_state(void* self, void* timer);
void Layout_update_state(void* self, void* state, void* timer);
char const* Layout_update_state_as_json(void* self, void* state, void* timer);
char const* Layout_state_as_json(void* self, void* timer);
void Layout_push(void* self, void* component);
void Layout_scroll_up(void* self);
void Layout_scroll_down(void* self);
void Layout_remount(void* self);

void* LayoutEditor_new(void* layout);
void* LayoutEditor_close(void* self);
char const* LayoutEditor_state_as_json(void* self);
void* LayoutEditor_state(void* self);
char const* LayoutEditor_layout_state_as_json(void* self, void* timer);
void LayoutEditor_select(void* self, size_t index);
void LayoutEditor_add_component(void* self, void* component);
void LayoutEditor_remove_component(void* self);
void LayoutEditor_move_component_up(void* self);
void LayoutEditor_move_component_down(void* self);
void LayoutEditor_move_component(void* self, size_t dst_index);
void LayoutEditor_duplicate_component(void* self);
void LayoutEditor_set_component_settings_value(void* self, size_t index, void* value);
void LayoutEditor_set_general_settings_value(void* self, size_t index, void* value);

void LayoutEditorState_drop(void* self);
size_t LayoutEditorState_component_len(void* self);
char const* LayoutEditorState_component_text(void* self, size_t index);
uint8_t LayoutEditorState_buttons(void* self);
uint32_t LayoutEditorState_selected_component(void* self);
size_t LayoutEditorState_field_len(void* self, bool component_settings);
char const* LayoutEditorState_field_text(void* self, bool component_settings, size_t index);
void* LayoutEditorState_field_value(void* self, bool component_settings, size_t index);

void* LayoutState_new(void);
void LayoutState_drop(void* self);
char const* LayoutState_as_json(void* self);
size_t LayoutState_len(void* self);
char const* LayoutState_component_type(void* self, size_t index);
void* LayoutState_component_as_blank_space(void* self, size_t index);
void* LayoutState_component_as_detailed_timer(void* self, size_t index);
void* LayoutState_component_as_graph(void* self, size_t index);
void* LayoutState_component_as_key_value(void* self, size_t index);
void* LayoutState_component_as_separator(void* self, size_t index);
void* LayoutState_component_as_splits(void* self, size_t index);
void* LayoutState_component_as_text(void* self, size_t index);
void* LayoutState_component_as_timer(void* self, size_t index);
void* LayoutState_component_as_title(void* self, size_t index);

void ParseRunResult_drop(void* self);
void* ParseRunResult_unwrap(void* self);
bool ParseRunResult_parsed_successfully(void* self);
char const* ParseRunResult_timer_kind(void* self);
bool ParseRunResult_is_generic_timer(void* self);

void* PbChanceComponent_new(void);
void PbChanceComponent_drop(void* self);
void* PbChanceComponent_into_generic(void* self);
char const* PbChanceComponent_state_as_json(void* self, void* timer);
void* PbChanceComponent_state(void* self, void* timer);

void* PossibleTimeSaveComponent_new(void);
void PossibleTimeSaveComponent_drop(void* self);
void* PossibleTimeSaveComponent_into_generic(void* self);
char const* PossibleTimeSaveComponent_state_as_json(void* self, void* timer);
void* PossibleTimeSaveComponent_state(void* self, void* timer);

void PotentialCleanUp_drop(void* self);
char const* PotentialCleanUp_message(void* self);

void* PreviousSegmentComponent_new(void);
void PreviousSegmentComponent_drop(void* self);
void* PreviousSegmentComponent_into_generic(void* self);
char const* PreviousSegmentComponent_state_as_json(void* self, void* timer, void* layout_settings);
void* PreviousSegmentComponent_state(void* self, void* timer, void* layout_settings);

void* Run_new(void);
void* Run_parse(void* data, size_t length, char const* path, bool load_files);
void* Run_parse_file_handle(int64_t handle, char const* path, bool load_files);
void Run_drop(void* self);
void* Run_clone(void* self);
char const* Run_game_name(void* self);
void* Run_game_icon_ptr(void* self);
size_t Run_game_icon_len(void* self);
char const* Run_category_name(void* self);
char const* Run_extended_file_name(void* self, bool use_extended_category_name);
char const* Run_extended_name(void* self, bool use_extended_category_name);
char const* Run_extended_category_name(void* self, bool show_region, bool show_platform, bool show_variables);
uint32_t Run_attempt_count(void* self);
void* Run_metadata(void* self);
void* Run_offset(void* self);
size_t Run_len(void* self);
bool Run_has_been_modified(void* self);
void* Run_segment(void* self, size_t index);
size_t Run_attempt_history_len(void* self);
void* Run_attempt_history_index(void* self, size_t index);
char const* Run_save_as_lss(void* self);
size_t Run_custom_comparisons_len(void* self);
char const* Run_custom_comparison(void* self, size_t index);
char const* Run_auto_splitter_settings(void* self);
void Run_push_segment(void* self, void* segment);
void Run_set_game_name(void* self, char const* game);
void Run_set_category_name(void* self, char const* category);
void Run_mark_as_modified(void* self);

void* RunEditor_new(void* run);
void* RunEditor_close(void* self);
char const* RunEditor_state_as_json(void* self);
void RunEditor_select_timing_method(void* self, uint8_t method);
void RunEditor_unselect(void* self, size_t index);
void RunEditor_select_additionally(void* self, size_t index);
void RunEditor_select_only(void* self, size_t index);
void RunEditor_set_game_name(void* self, char const* game);
void RunEditor_set_category_name(void* self, char const* category);
bool RunEditor_parse_and_set_offset(void* self, char const* offset);
bool RunEditor_parse_and_set_attempt_count(void* self, char const* attempts);
void RunEditor_set_game_icon(void* self, void* data, size_t length);
void RunEditor_remove_game_icon(void* self);
void RunEditor_set_run_id(void* self, char const* name);
void RunEditor_set_region_name(void* self, char const* name);
void RunEditor_set_platform_name(void* self, char const* name);
void RunEditor_set_emulator_usage(void* self, bool uses_emulator);
void RunEditor_set_speedrun_com_variable(void* self, char const* name, char const* value);
void RunEditor_remove_speedrun_com_variable(void* self, char const* name);
void RunEditor_add_custom_variable(void* self, char const* name);
void RunEditor_set_custom_variable(void* self, char const* name, char const* value);
void RunEditor_remove_custom_variable(void* self, char const* name);
void RunEditor_clear_metadata(void* self);
void RunEditor_insert_segment_above(void* self);
void RunEditor_insert_segment_below(void* self);
void RunEditor_remove_segments(void* self);
void RunEditor_move_segments_up(void* self);
void RunEditor_move_segments_down(void* self);
void RunEditor_active_set_icon(void* self, void* data, size_t length);
void RunEditor_active_remove_icon(void* self);
void RunEditor_active_set_name(void* self, char const* name);
bool RunEditor_active_parse_and_set_split_time(void* self, char const* time);
bool RunEditor_active_parse_and_set_segment_time(void* self, char const* time);
bool RunEditor_active_parse_and_set_best_segment_time(void* self, char const* time);
bool RunEditor_active_parse_and_set_comparison_time(void* self, char const* comparison, char const* time);
bool RunEditor_add_comparison(void* self, char const* comparison);
bool RunEditor_import_comparison(void* self, void* run, char const* comparison);
void RunEditor_remove_comparison(void* self, char const* comparison);
bool RunEditor_rename_comparison(void* self, char const* old_name, char const* new_name);
bool RunEditor_move_comparison(void* self, size_t src_index, size_t dst_index);
bool RunEditor_parse_and_generate_goal_comparison(void* self, char const* time);
void RunEditor_clear_history(void* self);
void RunEditor_clear_times(void* self);
void* RunEditor_clean_sum_of_best(void* self);

char const* RunMetadata_run_id(void* self);
char const* RunMetadata_platform_name(void* self);
bool RunMetadata_uses_emulator(void* self);
char const* RunMetadata_region_name(void* self);
void* RunMetadata_speedrun_com_variables(void* self);
void* RunMetadata_custom_variables(void* self);

void RunMetadataCustomVariable_drop(void* self);
char const* RunMetadataCustomVariable_name(void* self);
char const* RunMetadataCustomVariable_value(void* self);
bool RunMetadataCustomVariable_is_permanent(void* self);

void RunMetadataCustomVariablesIter_drop(void* self);
void* RunMetadataCustomVariablesIter_next(void* self);

void RunMetadataSpeedrunComVariable_drop(void* self);
char const* RunMetadataSpeedrunComVariable_name(void* self);
char const* RunMetadataSpeedrunComVariable_value(void* self);

void RunMetadataSpeedrunComVariablesIter_drop(void* self);
void* RunMetadataSpeedrunComVariablesIter_next(void* self);

void* Segment_new(char const* name);
void Segment_drop(void* self);
char const* Segment_name(void* self);
void* Segment_icon_ptr(void* self);
size_t Segment_icon_len(void* self);
void* Segment_comparison(void* self, char const* comparison);
void* Segment_personal_best_split_time(void* self);
void* Segment_best_segment_time(void* self);
void* Segment_segment_history(void* self);

void* SegmentHistory_iter(void* self);

int32_t SegmentHistoryElement_index(void* self);
void* SegmentHistoryElement_time(void* self);

void SegmentHistoryIter_drop(void* self);
void* SegmentHistoryIter_next(void* self);

void* SegmentTimeComponent_new(void);
void SegmentTimeComponent_drop(void* self);
void* SegmentTimeComponent_into_generic(void* self);
char const* SegmentTimeComponent_state_as_json(void* self, void* timer);
void* SegmentTimeComponent_state(void* self, void* timer);

void* SeparatorComponent_new(void);
void SeparatorComponent_drop(void* self);
void* SeparatorComponent_into_generic(void* self);
void* SeparatorComponent_state(void* self);

void SeparatorComponentState_drop(void* self);

void* SettingValue_from_bool(bool value);
void* SettingValue_from_uint(uint32_t value);
void* SettingValue_from_int(int32_t value);
void* SettingValue_from_string(char const* value);
void* SettingValue_from_optional_string(char const* value);
void* SettingValue_from_optional_empty_string(void);
void* SettingValue_from_float(double value);
void* SettingValue_from_accuracy(char const* value);
void* SettingValue_from_digits_format(char const* value);
void* SettingValue_from_optional_timing_method(char const* value);
void* SettingValue_from_optional_empty_timing_method(void);
void* SettingValue_from_color(float r, float g, float b, float a);
void* SettingValue_from_optional_color(float r, float g, float b, float a);
void* SettingValue_from_optional_empty_color(void);
void* SettingValue_from_transparent_gradient(void);
void* SettingValue_from_vertical_gradient(float r1, float g1, float b1, float a1, float r2, float g2, float b2, float a2);
void* SettingValue_from_horizontal_gradient(float r1, float g1, float b1, float a1, float r2, float g2, float b2, float a2);
void* SettingValue_from_alternating_gradient(float r1, float g1, float b1, float a1, float r2, float g2, float b2, float a2);
void* SettingValue_from_alignment(char const* value);
void* SettingValue_from_column_start_with(char const* value);
void* SettingValue_from_column_update_with(char const* value);
void* SettingValue_from_column_update_trigger(char const* value);
void* SettingValue_from_layout_direction(char const* value);
void* SettingValue_from_font(char const* family, char const* style, char const* weight, char const* stretch);
void* SettingValue_from_empty_font(void);
void SettingValue_drop(void* self);
char const* SettingValue_as_json(void* self);

void SharedTimer_drop(void* self);
void* SharedTimer_share(void* self);
void* SharedTimer_read(void* self);
void* SharedTimer_write(void* self);
void SharedTimer_replace_inner(void* self, void* timer);

void* SplitsComponent_new(void);
void SplitsComponent_drop(void* self);
void* SplitsComponent_into_generic(void* self);
char const* SplitsComponent_state_as_json(void* self, void* timer, void* layout_settings);
void* SplitsComponent_state(void* self, void* timer, void* layout_settings);
void SplitsComponent_scroll_up(void* self);
void SplitsComponent_scroll_down(void* self);
void SplitsComponent_set_visual_split_count(void* self, size_t count);
void SplitsComponent_set_split_preview_count(void* self, size_t count);
void SplitsComponent_set_always_show_last_split(void* self, bool always_show_last_split);
void SplitsComponent_set_separator_last_split(void* self, bool separator_last_split);

void SplitsComponentState_drop(void* self);
bool SplitsComponentState_final_separator_shown(void* self);
size_t SplitsComponentState_len(void* self);
size_t SplitsComponentState_icon_change_count(void* self);
size_t SplitsComponentState_icon_change_segment_index(void* self, size_t icon_change_index);
void* SplitsComponentState_icon_change_icon_ptr(void* self, size_t icon_change_index);
size_t SplitsComponentState_icon_change_icon_len(void* self, size_t icon_change_index);
char const* SplitsComponentState_name(void* self, size_t index);
size_t SplitsComponentState_columns_len(void* self, size_t index);
char const* SplitsComponentState_column_value(void* self, size_t index, size_t column_index);
char const* SplitsComponentState_column_semantic_color(void* self, size_t index, size_t column_index);
bool SplitsComponentState_is_current_split(void* self, size_t index);

void SumOfBestCleaner_drop(void* self);
void* SumOfBestCleaner_next_potential_clean_up(void* self);
void SumOfBestCleaner_apply(void* self, void* clean_up);

void* SumOfBestComponent_new(void);
void SumOfBestComponent_drop(void* self);
void* SumOfBestComponent_into_generic(void* self);
char const* SumOfBestComponent_state_as_json(void* self, void* timer);
void* SumOfBestComponent_state(void* self, void* timer);

void* TextComponent_new(void);
void TextComponent_drop(void* self);
void* TextComponent_into_generic(void* self);
char const* TextComponent_state_as_json(void* self, void* timer);
void* TextComponent_state(void* self, void* timer);
void TextComponent_set_center(void* self, char const* text);
void TextComponent_set_left(void* self, char const* text);
void TextComponent_set_right(void* self, char const* text);

void TextComponentState_drop(void* self);
char const* TextComponentState_left(void* self);
char const* TextComponentState_right(void* self);
char const* TextComponentState_center(void* self);
bool TextComponentState_is_split(void* self);

void Time_drop(void* self);
void* Time_clone(void* self);
void* Time_real_time(void* self);
void* Time_game_time(void* self);
void* Time_index(void* self, uint8_t timing_method);

void* TimeSpan_from_seconds(double seconds);
void* TimeSpan_parse(char const* text);
void TimeSpan_drop(void* self);
void* TimeSpan_clone(void* self);
double TimeSpan_total_seconds(void* self);

void* Timer_new(void* run);
void* Timer_into_shared(void* self);
void* Timer_into_run(void* self, bool update_splits);
void Timer_drop(void* self);
uint8_t Timer_current_timing_method(void* self);
char const* Timer_current_comparison(void* self);
bool Timer_is_game_time_initialized(void* self);
bool Timer_is_game_time_paused(void* self);
void* Timer_loading_times(void* self);
uint8_t Timer_current_phase(void* self);
void* Timer_get_run(void* self);
char const* Timer_save_as_lss(void* self);
void Timer_print_debug(void* self);
void* Timer_current_time(void* self);
bool Timer_replace_run(void* self, void* run, bool update_splits);
void* Timer_set_run(void* self, void* run);
void Timer_start(void* self);
void Timer_split(void* self);
void Timer_split_or_start(void* self);
void Timer_skip_split(void* self);
void Timer_undo_split(void* self);
void Timer_reset(void* self, bool update_splits);
void Timer_reset_and_set_attempt_as_pb(void* self);
void Timer_pause(void* self);
void Timer_resume(void* self);
void Timer_toggle_pause(void* self);
void Timer_toggle_pause_or_start(void* self);
void Timer_undo_all_pauses(void* self);
void Timer_set_current_timing_method(void* self, uint8_t method);
void Timer_switch_to_next_comparison(void* self);
void Timer_switch_to_previous_comparison(void* self);
void Timer_initialize_game_time(void* self);
void Timer_deinitialize_game_time(void* self);
void Timer_pause_game_time(void* self);
void Timer_resume_game_time(void* self);
void Timer_set_game_time(void* self, void* time);
void Timer_set_loading_times(void* self, void* time);
void Timer_mark_as_unmodified(void* self);

void* TimerComponent_new(void);
void TimerComponent_drop(void* self);
void* TimerComponent_into_generic(void* self);
char const* TimerComponent_state_as_json(void* self, void* timer, void* layout_settings);
void* TimerComponent_state(void* self, void* timer, void* layout_settings);

void TimerComponentState_drop(void* self);
char const* TimerComponentState_time(void* self);
char const* TimerComponentState_fraction(void* self);
char const* TimerComponentState_semantic_color(void* self);

void TimerReadLock_drop(void* self);
void* TimerReadLock_timer(void* self);

void TimerWriteLock_drop(void* self);
void* TimerWriteLock_timer(void* self);

void* TitleComponent_new(void);
void TitleComponent_drop(void* self);
void* TitleComponent_into_generic(void* self);
char const* TitleComponent_state_as_json(void* self, void* timer);
void* TitleComponent_state(void* self, void* timer);

void TitleComponentState_drop(void* self);
void* TitleComponentState_icon_change_ptr(void* self);
size_t TitleComponentState_icon_change_len(void* self);
char const* TitleComponentState_line1(void* self);
char const* TitleComponentState_line2(void* self);
bool TitleComponentState_is_centered(void* self);
bool TitleComponentState_shows_finished_runs(void* self);
uint32_t TitleComponentState_finished_runs(void* self);
bool TitleComponentState_shows_attempts(void* self);
uint32_t TitleComponentState_attempts(void* self);

void* TotalPlaytimeComponent_new(void);
void TotalPlaytimeComponent_drop(void* self);
void* TotalPlaytimeComponent_into_generic(void* self);
char const* TotalPlaytimeComponent_state_as_json(void* self, void* timer);
void* TotalPlaytimeComponent_state(void* self, void* timer);

#ifdef __cplusplus
}
}
#endif

#endif
