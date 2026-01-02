import discourseTags from "discourse/helpers/discourse-tags";

const TopicTags = <template>
  {{#if @topic.tags}}
    <div class="topic-card__topic-tags">
      {{discourseTags @topic mode="list" tagsForUser=@tagsForUser}}
    </div>
  {{/if}}
</template>;

export default TopicTags;
