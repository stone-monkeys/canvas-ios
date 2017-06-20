/* @flow */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import ReactNative, {
  View,
  StyleSheet,
  LayoutAnimation,
  Alert,
  ActionSheetIOS,
  PickerIOS,
  DatePickerIOS,
  Image,
} from 'react-native'
import i18n from 'format-message'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import Button from 'react-native-button'
import moment from 'moment'

import Screen from '../../../routing/Screen'
import { Heading1 } from '../../../common/text'
import Row from '../../../common/components/rows/Row'
import RowWithTextInput from '../../../common/components/rows/RowWithTextInput'
import RowWithSwitch from '../../../common/components/rows/RowWithSwitch'
import RowWithDetail from '../../../common/components/rows/RowWithDetail'
import colors from '../../../common/colors'
import RichTextEditor from '../../../common/components/rich-text-editor/RichTextEditor'
import Images from '../../../images'
import ModalActivityIndicator from '../../../common/components/ModalActivityIndicator'
import { default as EditDiscussionActions } from '../../discussions/edit/actions'
import { ERROR_TITLE } from '../../../redux/middleware/error-handler'
import { GRADE_DISPLAY_OPTIONS } from '../../assignment-details/AssignmentDetailsEdit'
import AssignmentDatesEditor from '../../assignment-details/components/AssignmentDatesEditor'
import { default as AssignmentsActions } from '../../assignments/actions'
import UnmetRequirementBanner from '../../../common/components/UnmetRequirementBanner'
import RequiredFieldSubscript from '../../../common/components/RequiredFieldSubscript'
import { extractDateFromString } from '../../../utils/dateUtils'

const {
  createDiscussion,
  deletePendingNewDiscussion,
  updateDiscussion,
  deleteDiscussion,
  subscribeDiscussion,
} = EditDiscussionActions

const { updateAssignment } = AssignmentsActions

const Actions = {
  createDiscussion,
  updateDiscussion,
  deletePendingNewDiscussion,
  deleteDiscussion,
  subscribeDiscussion,
  updateAssignment,
}

const PickerItem = PickerIOS.Item

type OwnProps = {
  discussionID: ?string,
  courseID: string,
}

type State = {
  title: ?string,
  message: ?string,
  published: ?boolean,
  discussion_type: ?DiscussionType,
  subscribed: ?boolean,
  require_initial_post: ?boolean,
  delayed_post_at: ?string,
  lock_at: ?string,
  can_unpublish: ?boolean,
  assignment: ?Assignment,
}

export type Props = State & OwnProps & AsyncState & NavigationProps & typeof Actions & {
  defaultDate?: ?Date,
}

const DELETE_ACTION_SHEET_BUTTON_INDEX = {
  destructive: 0,
  cancel: 1,
}

export class DiscussionEdit extends Component<any, Props, any> {
  scrollView: KeyboardAwareScrollView
  datesEditor: AssignmentDatesEditor

  constructor (props: Props) {
    super(props)

    const { assignment } = props

    this.state = {
      title: props.title,
      message: props.message,
      published: props.published,
      discussion_type: props.discussion_type || 'side_comment',
      subscribed: props.subscribed,
      require_initial_post: props.require_initial_post,
      lock_at: props.lock_at,
      delayed_post_at: props.delayed_post_at,
      assignment: props.assignment,
      points_possible: assignment ? assignment.points_possible : null,
      grading_type: assignment ? assignment.grading_type : 'points',
      can_unpublish: props.can_unpublish == null || props.can_unpublish,
      gradingTypePickerShown: false,
      showingDatePicker: {
        delayed_post_at: false,
        lock_at: false,
      },
      errors: {},
    }
  }

  componentWillUnmount () {
    this.props.deletePendingNewDiscussion(this.props.courseID)
  }

  componentWillReceiveProps (props: Props) {
    const error = props.error
    if (error) {
      this.setState({ pending: false })
      this._handleError(error)
      return
    }

    if (this.state.pending && !props.pending) {
      this.setState({ pending: false })
      this.props.navigator.dismissAllModals()
      return
    }

    if (!this.state.pending) {
      this.setState({
        title: props.title,
        message: props.message,
        published: props.published,
        discussion_type: props.discussion_type || 'side_comment',
        subscribed: props.subscribed,
        require_initial_post: props.require_initial_post,
        lock_at: props.lock_at,
        delayed_post_at: props.delayed_post_at,
        assignment: props.assignment,
        can_unpublish: props.can_unpublish == null || props.can_unpublish,
      })
    }
  }

  render () {
    const title = this.props.discussionID ? i18n('Edit') : i18n('New')
    const defaultDate = this.props.defaultDate || new Date()

    return (
      <Screen
        title={i18n('{title} Discussion', { title })}
        rightBarButtons={[
          {
            title: i18n('Done'),
            testID: 'discussions.edit.doneButton',
            style: 'done',
            action: this._donePressed,
            disabled: !this.state.message,
          },
        ]}
        leftBarButtons={[
          {
            title: i18n('Cancel'),
            testID: 'discussions.edit.cancelButton',
            style: 'cancel',
            action: this._cancelPressed,
          },
        ]}
      >
        <View style={{ flex: 1 }}>
          <ModalActivityIndicator text={i18n('Saving')} visible={this.state.pending}/>
          <UnmetRequirementBanner
            text={i18n('Invalid field')}
            visible={Boolean(Object.keys(this.state.errors).length)}
            testID='discussions.edit.unmet-requirement-banner'
          />
          <KeyboardAwareScrollView
            style={style.container}
            keyboardShouldPersistTaps='handled'
            enableAutoAutomaticScroll={false}
            ref={(r) => { this.scrollView = r }}
          >
            <Heading1 style={style.heading}>{i18n('Title')}</Heading1>
            <RowWithTextInput
              defaultValue={this.state.title}
              border='both'
              onChangeText={this._valueChanged('title')}
              identifier='discussions.edit.titleInput'
              placeholder={i18n('Add title')}
              onFocus={this._scrollToInput}
            />

            <Heading1 style={style.heading}>{i18n('Description')}</Heading1>
            <View
              style={style.description}
            >
              <RichTextEditor
                onChangeValue={this._valueChanged('message')}
                defaultValue={this.props.message}
                showToolbar='always'
                keyboardAware={false}
                scrollEnabled={true}
                contentHeight={150}
                placeholder={i18n('Add description (required)')}
              />
            </View>
            <RequiredFieldSubscript
              title={this.state.errors.message}
              visible={Boolean(this.state.errors.message)}
              testID='discussions.edit.message.validation-error'
            />

            <Heading1 style={style.heading}>{i18n('Options')}</Heading1>
            { this.state.can_unpublish &&
              <RowWithSwitch
                title={i18n('Publish')}
                border='both'
                value={this.state.published}
                onValueChange={this._valueChanged('published')}
                testID='discussions.edit.published.switch'
              />
            }
            <RowWithSwitch
              title={i18n('Allow threaded replies')}
              border='bottom'
              value={this.state.discussion_type === 'threaded'}
              onValueChange={this._valueChanged('discussion_type', b => b ? 'threaded' : 'side_comment')}
              identifier='discussions.edit.discussion_type.switch'
            />
            <RowWithSwitch
              title={i18n('Subscribe')}
              border='bottom'
              value={this.state.subscribed}
              onValueChange={this._subscribe}
              identifier='discussions.edit.subscribed.switch'
            />
            <RowWithSwitch
              title={i18n('Users must post before seeing replies')}
              border='bottom'
              value={this.state.require_initial_post}
              onValueChange={this._valueChanged('require_initial_post')}
            />
            { this.isGraded() &&
              <View>
                <RowWithTextInput
                  title={i18n('Points')}
                  border='bottom'
                  placeholder='0'
                  inputWidth={200}
                  onChangeText={this._valueChanged('points_possible')}
                  keyboardType='number-pad'
                  defaultValue={this.state.points_possible && String(this.state.points_possible)}
                  onFocus={this._scrollToInput}
                  identifier='discussions.edit.points_possible.input'
                />
                <RequiredFieldSubscript
                  title={this.state.errors.points_possible}
                  visible={Boolean(this.state.errors.points_possible)}
                  testID='discussions.edit.points_possible.validation-error'
                />
                <RowWithDetail
                  title={i18n('Display Grade as...')}
                  detail={GRADE_DISPLAY_OPTIONS.get(this.state.grading_type)}
                  disclosureIndicator={true}
                  border='bottom'
                  onPress={this._toggleGradingTypePicker}
                  testID='discussions.edit.grading_type.row'
                />
                { this.state.gradingTypePickerShown &&
                  <PickerIOS
                    selectedValue={this.state.grading_type}
                    onValueChange={this._valueChanged('grading_type', null, false)}
                    testID='discussions.edit.grading_type.picker'>
                    {Array.from(GRADE_DISPLAY_OPTIONS.keys()).map((key) => (
                      <PickerItem
                        key={key}
                        value={key}
                        label={GRADE_DISPLAY_OPTIONS.get(key)}
                      />
                    ))}
                  </PickerIOS>
                }
              </View>
            }

            { this.isGraded() &&
              <AssignmentDatesEditor
                assignment={this.state.assignment}
                ref={c => { this.datesEditor = c }}
                navigator={this.props.navigator}
              />
            }

            { !this.isGraded() &&
              <View>
                <Heading1 style={style.heading}>{i18n('Availability')}</Heading1>
                <RowWithDetail
                  title={i18n('Available from')}
                  detail={this.state.delayed_post_at ? moment(this.state.delayed_post_at).format(`MMM D  h:mm A`) : '--'}
                  border='bottom'
                  onPress={this._toggleDatePicker('delayed_post_at')}
                  testID='discussions.edit.delayed_post_at.row'
                  accessories={ Boolean(this.state.delayed_post_at) &&
                    <View style={{ marginLeft: 8 }}>
                      <Button
                        testID={`discussions.edit.clear-delayed-post-at.button`}
                        activeOpacity={1}
                        onPress={this._clearDate('delayed_post_at')}
                      >
                        <Image source={Images.clear} />
                      </Button>
                    </View>
                  }
                />
                { this.state.showingDatePicker.delayed_post_at &&
                  <DatePickerIOS
                    date={extractDateFromString(this.state.delayed_post_at) || defaultDate}
                    onDateChange={this._valueChanged('delayed_post_at', d => d.toISOString())}
                    testID='discussions.edit.delayed_post_at.picker'
                    accessories={ Boolean(this.state.delayed_post_at) &&
                      <View style={{ marginLeft: 8 }}>
                        <Button
                          testID={`discussions.edit.clear-delayed-post-at.button`}
                          activeOpacity={1}
                          onPress={this._clearDate('delayed_post_at')}
                        >
                          <Image source={Images.clear} />
                        </Button>
                      </View>
                    }
                  />
                }
                <RowWithDetail
                  title={i18n('Available until')}
                  detail={this.state.lock_at ? moment(this.state.lock_at).format(`MMM D  h:mm A`) : '--'}
                  border='bottom'
                  onPress={this._toggleDatePicker('lock_at')}
                  testID='discussions.edit.lock_at.row'
                  accessories={ Boolean(this.state.lock_at) &&
                    <View style={{ marginLeft: 8 }}>
                      <Button
                        testID={`discussions.edit.clear-lock-at.button`}
                        activeOpacity={1}
                        onPress={this._clearDate('lock_at')}
                      >
                        <Image source={Images.clear} />
                      </Button>
                    </View>
                  }
                />
                { this.state.showingDatePicker.lock_at &&
                  <DatePickerIOS
                    date={extractDateFromString(this.state.lock_at) || defaultDate}
                    onDateChange={this._valueChanged('lock_at', d => d.toISOString())}
                    testID='discussions.edit.lock_at.picker'
                  />
                }
                <Heading1 style={style.heading}> </Heading1>
              </View>
            }

            { Boolean(this.props.discussionID) &&
              <View>
                <Row
                  title={i18n('Delete Discussion')}
                  image={Images.trash}
                  testID='discussions.edit.deleteButton'
                  onPress={this._showDeleteConfirmation}
                  titleStyles={style.deleteButtonTitle}
                />
                <Heading1 style={style.heading}> </Heading1>
              </View>
            }
          </KeyboardAwareScrollView>
        </View>
      </Screen>
    )
  }

  _valueChanged (property: string, transformer?: any, animated?: boolean = true): Function {
    return (value) => {
      if (transformer) { value = transformer(value) }
      this._valuesChanged({ [property]: value }, animated)
    }
  }

  _valuesChanged (values: Object, animated?: boolean) {
    if (animated) {
      LayoutAnimation.easeInEaseOut()
    }
    this.setState({ ...values })
  }

  _donePressed = () => {
    if (!this.validate()) {
      return
    }
    this.setState({ pending: true })
    this.updateAssignment()
    this.updateDiscussion()
  }

  _cancelPressed = () => {
    this.props.navigator.dismiss()
  }

  _scrollToInput = (event: any) => {
    const input = ReactNative.findNodeHandle(event.target)
    this.scrollView.scrollToFocusedInput(input)
  }

  _handleError (error: string) {
    setTimeout(() => {
      Alert.alert(ERROR_TITLE, error)
    }, 1000)
  }

  _showDeleteConfirmation = () => {
    const { destructive, cancel } = DELETE_ACTION_SHEET_BUTTON_INDEX
    const options = {
      title: i18n('Are you sure you want to delete this discussion?'),
      options: [i18n('Delete'), i18n('Cancel')],
      destructiveButtonIndex: destructive,
      cancelButtonIndex: cancel,
    }
    ActionSheetIOS.showActionSheetWithOptions(options, this._handleDeleteActionSheet)
  }

  _handleDeleteActionSheet = (index: number) => {
    index === DELETE_ACTION_SHEET_BUTTON_INDEX.destructive && this._deleteDiscussion()
  }

  _deleteDiscussion = () => {
    this.setState({ pending: true })
    this.props.deleteDiscussion(this.props.courseID, this.props.discussionID)
  }

  _toggleGradingTypePicker = () => {
    LayoutAnimation.easeInEaseOut()
    this.setState({
      gradingTypePickerShown: !this.state.gradingTypePickerShown,
    })
  }

  _toggleDatePicker = (dateField) => {
    return () => {
      const willShow = !this.state.showingDatePicker[dateField]
      if (willShow && !this.state[dateField]) {
        this._valueChanged(dateField, null, false)(this.props.defaultDate || new Date())
      }
      this.setState({
        showingDatePicker: {
          ...this.state.showingDatePicker,
          [dateField]: willShow,
        },
      })
    }
  }

  _clearDate = (dateField) => {
    return () => {
      LayoutAnimation.easeInEaseOut()
      this.setState({
        [dateField]: null,
        showingDatePicker: {
          ...this.state.showingDatePicker,
          [dateField]: false,
        },
      })
    }
  }

  _subscribe = (shouldSubscribe: boolean) => {
    this.props.subscribeDiscussion(this.props.courseID, this.props.discussionID, shouldSubscribe)
  }

  validate () {
    const errors = {}
    if (this.state.assignment && !this.datesEditor.validate()) {
      errors.dates = true
    }

    if (!this.state.message) {
      errors.message = i18n('A message is required')
    }

    const pointsPossible = Number(this.state.points_possible)
    if (isNaN(pointsPossible) || pointsPossible < 0) {
      errors.points_possible = i18n('The value of possible points must be zero or greater')
    }

    this.setState({ errors })

    return !Object.keys(errors).length
  }

  updateAssignment () {
    if (this.state.assignment) {
      const updatedAssignment = this.datesEditor.updateAssignment({ ...this.state.assignment })
      updatedAssignment.points_possible = this.state.points_possible
      updatedAssignment.grading_type = this.state.grading_type
      this.props.updateAssignment(this.props.courseID, updatedAssignment, this.props.assignment)
    }
  }

  updateDiscussion () {
    const params = {
      title: this.state.title === '' ? null : this.state.title,
      message: this.state.message,
      published: this.state.published || false,
      discussion_type: this.state.discussion_type || 'side_comment',
      subscribed: this.state.subscribed || false,
      require_initial_post: this.state.require_initial_post || false,
      lock_at: this.state.lock_at,
      delayed_post_at: this.state.delayed_post_at,
    }
    if (this.props.discussionID) {
      // $FlowFixMe
      params.id = this.props.discussionID
    }
    this.props.discussionID
      ? this.props.updateDiscussion(this.props.courseID, params)
      : this.props.createDiscussion(this.props.courseID, params)
  }

  isGraded = () => Boolean(this.state.assignment)
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  heading: {
    color: colors.darkText,
    marginLeft: global.style.defaultPadding,
    marginTop: global.style.defaultPadding,
    marginBottom: global.style.defaultPadding / 2,
  },
  description: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.seperatorColor,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.seperatorColor,
    backgroundColor: 'white',
    height: 200,
  },
  deleteButtonTitle: {
    color: '#EE0612',
  },
})

export function mapStateToProps ({ entities }: AppState, { courseID, discussionID }: OwnProps): State {
  let discussion = {}
  let error = null
  let pending = 0
  let assignment = null

  if (!discussionID &&
    entities.courses &&
    entities.courses[courseID] &&
    entities.courses[courseID].discussions &&
    entities.courses[courseID].discussions.new) {
    const newState = entities.courses[courseID].discussions.new
    error = newState.error
    pending = pending + (newState.pending || 0)
    discussionID = newState.id
  }

  if (discussionID &&
    entities.discussions &&
    entities.discussions[discussionID] &&
    entities.discussions[discussionID].data) {
    const entity = entities.discussions[discussionID]
    discussion = entity.data
    pending = pending + (entity.pending || 0)
    error = error || entity.error
  }

  if (discussion &&
    discussion.assignment_id &&
    entities.assignments &&
    entities.assignments[discussion.assignment_id] &&
    entities.assignments[discussion.assignment_id].data) {
    const assignmentEntity = entities.assignments[discussion.assignment_id]
    assignment = assignmentEntity.data
    pending = pending + (assignmentEntity.pending || 0)
    error = error || assignmentEntity.error
  }

  const {
    title,
    message,
    published,
    discussion_type,
    subscribed,
    require_initial_post,
    lock_at,
    delayed_post_at,
    can_unpublish,
  } = discussion
  return {
    title,
    message,
    published,
    discussion_type,
    subscribed,
    require_initial_post,
    delayed_post_at,
    lock_at,
    can_unpublish,
    assignment,
    pending,
    error,
  }
}

const Connected = connect(mapStateToProps, Actions)(DiscussionEdit)
export default (Connected: Component<any, Props, any>)
