package com.blog.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.blog.common.BusinessException;
import com.blog.entity.ArticleTag;
import com.blog.entity.Tag;
import com.blog.mapper.ArticleTagMapper;
import com.blog.mapper.TagMapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TagService {

    private final TagMapper tagMapper;
    private final ArticleTagMapper articleTagMapper;

    public TagService(TagMapper tagMapper, ArticleTagMapper articleTagMapper) {
        this.tagMapper = tagMapper;
        this.articleTagMapper = articleTagMapper;
    }

    public List<Tag> listAll() {
        return tagMapper.selectList(new LambdaQueryWrapper<Tag>().orderByAsc(Tag::getId));
    }

    public void create(Tag tag) {
        Long count = tagMapper.selectCount(
                new LambdaQueryWrapper<Tag>().eq(Tag::getName, tag.getName()));
        if (count > 0) {
            throw new BusinessException("标签名称已存在");
        }
        tagMapper.insert(tag);
    }

    public void update(Long id, Tag tag) {
        Tag existing = tagMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("标签不存在");
        }
        tag.setId(id);
        tagMapper.updateById(tag);
    }

    public void delete(Long id) {
        Long count = articleTagMapper.selectCount(
                new LambdaQueryWrapper<ArticleTag>().eq(ArticleTag::getTagId, id));
        if (count > 0) {
            throw new BusinessException("该标签还被文章使用，无法删除");
        }
        tagMapper.deleteById(id);
    }
}
