import ActivityCell from "discourse/components/topic-list/item/activity-cell";
import dIcon from "discourse/helpers/d-icon";
import formatDate from "discourse/helpers/format-date";
import { i18n } from "discourse-i18n";
import LikeToggle from "./like-toggle";

const TopicMetadata = <template>
  <div class="topic-card__metadata">
    {{#if settings.show_reply_count}}
      <span class="topic-card__reply_count item">
        {{dIcon "comment"}}
        <span class="number">
          {{@topic.replyCount}}
        </span>
      </span>
    {{/if}}

    {{#if settings.show_likes}}
      <span class="topic-card__likes item">
        <LikeToggle @topic={{@topic}} />
      </span>
    {{/if}}

    {{#if settings.show_views}}
      <span class="topic-card__views item">
        {{dIcon "eye"}}
        <span class="number">
          {{@topic.views}}
        </span>
      </span>
    {{/if}}
  </div>
</template>;

export default TopicMetadata;
