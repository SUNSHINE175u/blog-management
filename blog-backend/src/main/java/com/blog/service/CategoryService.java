package com.blog.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.blog.common.BusinessException;
import com.blog.entity.Category;
import com.blog.mapper.ArticleMapper;
import com.blog.mapper.CategoryMapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryService {

    private final CategoryMapper categoryMapper;
    private final ArticleMapper articleMapper;

    public CategoryService(CategoryMapper categoryMapper, ArticleMapper articleMapper) {
        this.categoryMapper = categoryMapper;
        this.articleMapper = articleMapper;
    }

    public List<Category> listAll() {
        return categoryMapper.selectList(new LambdaQueryWrapper<Category>().orderByAsc(Category::getId));
    }

    public Category getById(Long id) {
        return categoryMapper.selectById(id);
    }

    public void create(Category category) {
        Long count = categoryMapper.selectCount(
                new LambdaQueryWrapper<Category>().eq(Category::getName, category.getName()));
        if (count > 0) {
            throw new BusinessException("分类名称已存在");
        }
        categoryMapper.insert(category);
    }

    public void update(Long id, Category category) {
        Category existing = categoryMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("分类不存在");
        }
        category.setId(id);
        categoryMapper.updateById(category);
    }

    public void delete(Long id) {
        Long count = articleMapper.selectCount(
                new LambdaQueryWrapper<com.blog.entity.Article>().eq(com.blog.entity.Article::getCategoryId, id));
        if (count > 0) {
            throw new BusinessException("该分类下还有文章，无法删除");
        }
        categoryMapper.deleteById(id);
    }
}
