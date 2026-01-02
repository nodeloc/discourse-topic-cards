import UserLink from "discourse/components/user-link";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import and from "truth-helpers/helpers/and";
import gt from "truth-helpers/helpers/gt";

const TopicLastReply = <template>
  {{#if (and @topic.lastPosterUser (gt @topic.replyCount 0))}}
    <div class="topic-card__last-reply">
      <UserLink @user={{@topic.lastPosterUser}}>
        {{avatar @topic.lastPosterUser imageSize="tiny"}}
        <span class="username">{{@topic.lastPosterUser.username}}</span>
      </UserLink>
      <span class="time">replied {{formatDate @topic.bumpedAt format="tiny"}}</span>
    </div>
  {{/if}}
</template>;

export default TopicLastReply;
