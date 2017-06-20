/* @flow */

import { Reducer } from 'redux'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'
import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import { default as ListActions } from './list/actions'
import { default as DetailsActions } from './details/actions'
import { default as AnnouncementListActions } from '../announcements/list/actions'
import { default as EditActions } from './edit/actions'
import i18n from 'format-message'
import composeReducers from '../../redux/compose-reducers'

import { parseErrorMessage } from '../../redux/middleware/error-handler'

const { refreshDiscussions } = ListActions
const { refreshDiscussionEntries } = DetailsActions
const { refreshAnnouncements } = AnnouncementListActions
const {
  createDiscussion,
  deletePendingNewDiscussion,
  updateDiscussion,
  deleteDiscussion,
  subscribeDiscussion,
} = EditActions

const list: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshDiscussions.toString(),
  i18n('There was a problem loading discussions.'),
  ({ result }) => result.data.map(discussion => discussion.id)
)

const refsChanges: Reducer<AsyncRefs, any> = handleActions({
  [createDiscussion.toString()]: handleAsync({
    pending: (state) => ({
      ...state,
      new: {
        ...state.new,
        pending: 1,
        error: null,
        id: null,
      },
    }),
    resolved: (state, { result: { data } }) => ({
      ...state,
      refs: [...state.refs, data.id],
      new: {
        ...state.new,
        pending: 0,
        error: null,
        id: data.id,
      },
    }),
    rejected: (state, { error }) => ({
      ...state,
      new: {
        ...state.new,
        pending: 0,
        error: parseErrorMessage(error),
        id: null,
      },
    }),
  }),
  [deleteDiscussion.toString()]: handleAsync({
    resolved: (state, { discussionID }) => ({
      ...state,
      refs: (state.refs || []).filter(ref => ref !== discussionID),
    }),
  }),
  [deletePendingNewDiscussion.toString()]: (state) => ({
    ...state,
    new: null,
  }),
}, {})

export const refs: Reducer<AsyncRefs, any> = composeReducers(list, refsChanges)

const handleAsyncDiscussions = handleAsync({
  resolved: (state, { result }) => {
    const incoming = result.data
      .reduce((incoming, discussion) => ({
        ...incoming,
        [discussion.id]: {
          data: discussion,
          pending: 0,
          error: null,
        },
      }), {})
    return { ...state, ...incoming }
  },
})

export const discussionData: Reducer<DiscussionState, any> = handleActions({
  [refreshDiscussions.toString()]: handleAsyncDiscussions,
  [refreshAnnouncements.toString()]: handleAsyncDiscussions,
  [refreshDiscussionEntries.toString()]: handleAsync({
    resolved: (state, { result, courseID, discussionID }) => {
      let entity = { ...state[discussionID] } || {}
      entity.data = entity.data || {}
      if (entity.data) {
        let participantsAsMap = result.data.participants.reduce((map, p) => ({ ...map, [p.id]: p }), {})
        entity.data = { ...entity.data, replies: result.data.view, participants: participantsAsMap }
      }
      return {
        ...state,
        [discussionID]: {
          ...entity,
          pending: state[discussionID] && state[discussionID].pending ? state[discussionID].pending - 1 : 0,
          error: null,
        },
      }
    },
  }),
  [createDiscussion.toString()]: handleAsync({
    resolved: (state, { result: { data } }) => ({
      ...state,
      [data.id]: {
        data,
        pending: 0,
        error: null,
      },
    }),
  }),
  [updateDiscussion.toString()]: handleAsync({
    pending: (state, { params }) => ({
      ...state,
      [params.id]: {
        ...state[params.id],
        pending: (state[params.id] && state[params.id].pending || 0) + 1,
        error: null,
      },
    }),
    resolved: (state, { params, result: { data } }) => ({
      ...state,
      [params.id]: {
        ...state[params.id],
        data,
        pending: (state[params.id] && state[params.id].pending || 1) - 1,
        error: null,
      },
    }),
    rejected: (state, { params, error }) => ({
      ...state,
      [params.id]: {
        ...state[params.id],
        pending: (state[params.id] && state[params.id].pending || 1) - 1,
        error: parseErrorMessage(error),
      },
    }),
  }),
  [deleteDiscussion.toString()]: handleAsync({
    pending: (state, { discussionID }) => ({
      ...state,
      [discussionID]: {
        ...state[discussionID],
        pending: (state[discussionID] && state[discussionID].pending || 0) + 1,
        error: null,
      },
    }),
    resolved: (state, { discussionID }) => {
      return Object.keys(state).reduce((incoming, current) => {
        return current === discussionID ? incoming : { ...incoming, [current]: state[current] }
      }, {})
    },
    rejected: (state, { discussionID, error }) => ({
      ...state,
      [discussionID]: {
        ...state[discussionID],
        pending: (state[discussionID] && state[discussionID].pending || 1) - 1,
        error: parseErrorMessage(error),
      },
    }),
  }),
  [subscribeDiscussion.toString()]: handleAsync({
    pending: (state, { discussionID, subscribed }) => ({
      ...state,
      [discussionID]: {
        ...state[discussionID],
        data: {
          ...(state[discussionID] && state[discussionID].data),
          subscribed,
        },
      },
    }),
    rejected: (state, { discussionID, subscribed }) => ({
      ...state,
      [discussionID]: {
        ...state[discussionID],
        data: {
          ...(state[discussionID] && state[discussionID].data),
          subscribed: !subscribed,
        },
      },
    }),
  }),
}, {})

export function discussions (state: any = {}, action: any): any {
  let newState = state
  return discussionData(newState, action)
}
